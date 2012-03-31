module Facebase
  class EmailsController < ApplicationController
    before_filter :authenticate_admin!

    def index
      templates = Facebase::S3::EmailTemplateManager.instance.s3_email_templates

      @template_tree = Facebase::Email.template_tree
      pp @template_tree
    end

    def fb_tester

    end

    def preview
      campaign = params[:campaign]
      stream = params[:stream]
      component = params[:component]
      force_refresh=true

      contact = Facebase::Contact.random_shard.first

      @template_values = {}
      @template_values[:sender_name] = "Timothy Cardneas"
      @template_values[:recipient_name] = "Sean Cardenas"
      @template_values[:recipient_date] = Time.now.strftime("%B #{Time.now.day.ordinalize}")
      @template_values[:days_left] = (Time.now.advance(:days => 3).to_date - Time.now.to_date ).to_i
      @template_values[:recipient_facebook_id] = 214367
      @template_values[:event] = "Half Birthday"

      @_email = contact.emails.new(
        :campaign => campaign,
        :stream => stream,
        :component => component,
        :schedule_at => Time.now.to_i,
        :subject => "Email preview",
        :template_values => @template_values,
        :from => "reminder@davia.com",
        :reply_to => "reminder@davia.com",
        :email_service_provider_id => Facebase::EmailServiceProvider.first.id
      )
      @_email.save

      respond_to do |format|
        format.html { render :inline => @_email.html_erb(force_refresh) }
      end
    end

    def review(composite_id)
      id_bits = composite_id.split('-')
      email_shard = Facebase::Email.shard_for(id_bits[0])
      email = email_shard.find(id_bits[1])
      respond_to do |format|
        format.html { render html: email.parsed_html_content }
      end
    end


  end
end
