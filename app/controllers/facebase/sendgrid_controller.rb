module Facebase
  class SendgridController < ApplicationController

    # Parses a notification from the sendgrid system
    # ****** Careful if you use sendgrids open an click handlers you will want to forgo
    # mailspys tracking, otherwise a double count will occur *****
    def notification

      #Must be passed in via SendGrids SMTP API Headers
      com_id = params['com_id']
      return head 400 if com_id.blank? || params[:event].blank?

      # Ensure we have valid parameters
      profile_id = com_id.split("-").first.to_i
      email_id = com_id.split("-").last.to_i
      return head 400 if profile_id.blank? || email_id.blank?

      # Ensure we have a email and a contact
      email = Facebase::Email.shard_for(profile_id).find(email_id)
      contact = Facebase::Profile.shard_for(profile_id).find(profile_id).contact
      return head 400 if email.blank? || contact.blank?


      # Carve out exactly what to note from the notification
      case params[:event]
        when 'bounce'
          email.email_actions.create!(
            :action_type => Facebase::EmailActionModule::SENDGRID_BOUNCE,
            :details => {:reason => params[:reason], :type => params[:type], :status => params[:status]},
            :count => 1
          )
          contact.update_attribute(:bounced_email, true)
        when 'dropped'
          email.email_actions.create!(
            :action_type => Facebase::EmailActionModule::SENDGRID_DROPPED,
            :details => {:reason => params[:reason]},
            :count => 1
          )
        when 'click'
          email.email_actions.create!(
            :action_type => Facebase::EmailActionModule::SENDGRID_CLICK,
            :details => {:url => params[:url]},
            :count => 1
          )
          contact.update_attribute(:times_emails_clicked, contact.times_emails_clicked + 1)
        when 'delivered'
          email.email_actions.create!(
            :action_type => Facebase::EmailActionModule::SENDGRID_DELIVERED,
            :count => 1
          )
          contact.update_attribute(:emails_delivered, contact.emails_delivered + 1)
        when 'open'
          email.email_actions.create!(
            :action_type => Facebase::EmailActionModule::SENDGRID_OPEN,
            :count => 1
          )
          contact.update_attribute(:times_emails_opened, contact.times_emails_opened + 1)
        when 'spamreport'
          email.email_actions.create!(
            :action_type => Facebase::EmailActionModule::SENDGRID_SPAM,
            :count => 1
          )
          contact.update_attribute(:spam_email, true)
        when 'unsubscribe'
          email.email_actions.create!(
            :action_type => Facebase::EmailActionModule::SENDGRID_UNSUBSCRIBE,
            :count => 1
          )
          contact.update_attribute(:unsubscribed_email, true)
        when 'processed'
          email.email_actions.create!(
            :action_type => Facebase::EmailActionModule::SENDGRID_PROCESSED,
            :count => 1
          )
        when 'deferred'
          email.email_actions.create!(
            :action_type => Facebase::EmailActionModule::SENDGRID_DEFERRED,
            :count => 1
          )
      end

      head :ok
    end

  end
end
