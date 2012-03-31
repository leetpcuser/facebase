module Facebase
  class TrackingController < ApplicationController

    def link
      # Decompose the compound id
      profile_id, email_id = decompose_id(params[:com_id])

      # Find the related records from across all shards
      email = Facebase::Email.shard_for(profile_id).find(email_id)
      contact = Facebase::Profile.shard_for(profile_id).find(profile_id).contact

      # Update the tracking data
      contact.update_attribute(:times_emails_clicked, contact.times_emails_clicked + 1)
      email.email_actions.create!(
        :action_type => Facebase::EmailActionModule::MAIL_SPY_CLICK,
        :details => {
          :url => params[:url],
          :link_number => params[:n]
        }
      )

      # Mixpanel if enabled
      mixpanel_tracking(Facebase::EmailActionModule::MAIL_SPY_CLICK,
                        {
                          :token => Facebase.mixpanel_token,
                          :campaign => email.campaign,
                          :stream => email.stream,
                          :component => email.component,
                          :subject => email.subject,
                          :from => email.from,
                          :reply_to => email.reply_to,
                          :url => params[:url],
                          :link_number => params[:n]
                        })


      # Add in the GA tokens if present
      ga_hash = {}
      ga_hash[:utm_source] = email.utm_source if email.utm_source.present?
      ga_hash[:utm_medium] = email.utm_medium if email.utm_medium.present?
      ga_hash[:utm_campaign] = email.utm_campaign if email.utm_campaign.present?
      ga_hash[:utm_term] = email.utm_term if email.utm_term.present?
      ga_hash[:utm_content] = email.utm_content if email.utm_content.present?

      #TODO this is not fool proof, it breaks on bad urls (like missing http://)
      #TODO this also breaks when a param is already present it isn;t smart
      uri = URI.parse(params[:url])
      uri.query = [uri.query, ga_hash.to_param].compact.join('&')

      redirect_to uri.to_s
    rescue => e
      pp "Falling back to backup, Error occured, #{e.message}"
      pp e.backtrace
      redirect_to Facebase.tracker_fall_back_site
    end

    def bug
      head :unprocessable_entity and return if params[:com_id].blank?
      profile_id, email_id = decompose_id(params[:com_id])

      # Find the related records from across all shards
      email = Facebase::Email.shard_for(profile_id).find(email_id)
      contact = Facebase::Profile.shard_for(profile_id).find(profile_id).contact


      # Update the tracking data
      contact.update_attribute(:times_emails_opened, contact.times_emails_opened + 1)
      email.email_actions.create!(
        :action_type => Facebase::EmailActionModule::MAIL_SPY_OPEN
      )

      # Mixpanel if enabled
      mixpanel_tracking(Facebase::EmailActionModule::MAIL_SPY_OPEN,
                        {
                          :campaign => email.campaign,
                          :stream => email.stream,
                          :component => email.component,
                          :subject => email.subject,
                          :from => email.from,
                          :reply_to => email.reply_to,
                        })


      head 200
    end

    def unsubscribe
      profile_id, email_id = decompose_id(params[:com_id])

      # Find the related records from across all shards
      email = Facebase::Email.shard_for(profile_id).find(email_id)
      contact = Facebase::Profile.shard_for(profile_id).find(profile_id).contact


      contact.update_attribute(:unsubscribed_email, true)
      email.email_actions.create!(
        :action_type => Facebase::EmailActionModule::MAIL_SPY_UNSUBSCRIBE
      )

      # Mixpanel if enabled
      mixpanel_tracking(Facebase::EmailActionModule::MAIL_SPY_UNSUBSCRIBE,
                        {
                          :campaign => email.campaign,
                          :stream => email.stream,
                          :component => email.component,
                          :subject => email.subject,
                          :from => email.from,
                          :reply_to => email.reply_to,
                        })

      if Facebase.unsubscribe_url
        redirect_to Facebase.unsubscribe_url
      else
        render :text => "We are sorry to see you go. You are unsubscribed"
      end

    rescue => e
      pp "Falling back to backup, Error occured, #{e.message}"
      pp e.backtrace
      redirect_to Facebase.tracker_fall_back_site
    end

    def action
      # Lookup the email
      profile_id, email_id = decompose_id(params[:com_id])
      email = Facebase::Email.shard_for(profile_id).find(email_id)

      # Standardize the params
      action_type = params[:action_type]
      count = params[:count] || 1
      details = params[:details] || {}

      head :unprocessable_entity and return if action_type.blank?
      head :unprocessable_entity and return if details.present? && !details.kind_of?(Hash)

      # Create the record
      action_hash = {
        :action_type => action_type
      }
      action_hash[:count] = count if count.present?
      action_hash[:details] = count if details.present?
      email.email_actions.create!(action_hash)

      details ||= {}
      details[:campaign] = email.campaign
      details[:stream] = email.stream
      details[:component] = email.component
      details[:subject] = email.subject


      # Mixpanel if enabled
      mixpanel_tracking(action, details)

      head 200
    end

    protected

    def mixpanel_tracking(event, details={})
      details ||= {} # Ensure a correct hash
      if Facebase.mixpanel_token.present?
        begin
          # Forces the correct token per the client interface
          details[:token] = Facebase.mixpanel_token
          Facebase::MixpanelClient.track(event, details)
        rescue => e
          pp e.message
          pp e.backtrace
        end
      end
    end

    def decompose_id(compound_id)
      profile_id = compound_id.split("-").first.to_i
      email_id = compound_id.split("-").last.to_i
      return profile_id, email_id
    end


  end
end
