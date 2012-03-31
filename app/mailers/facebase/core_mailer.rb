module Facebase
  class CoreMailer < ActionMailer::Base
    helper "facebase/core_mailer"


    def template_from_email(email, force_refresh=false)
      template_options = {
        :headers => email.headers,
        :template_values => email.template_values,
        :to => email.to,
        :from => email.from,
        :reply_to => email.reply_to,
        :subject => email.subject,
        :composite_id => email.composite_id,
        :text_erb => email.text_erb(force_refresh),
        :html_erb => email.html_erb(force_refresh),
        :email_service_provider => email.email_service_provider
      }

      template(template_options)
    end

    # Template values may be passed in manually to sniff the template, force
    # refresh may be passed to allow debuggin of templates
    def template(options={})

      # ----------------------------------------- Template Prep
      # Template values used for replacement in the emails
      # *** '@template_values' is a convention used by all our emails templates, must not be renamed! ***
      options[:template_values] ||= {}
      @template_values = options[:template_values]

      # Required for custom link helpers
      @_composite_id = options[:composite_id]

      # ----------------------------------------- Email Construction
      # 'headers' is a action mailer method for setting the email headers
      options[:headers].each { |key, value| headers[key] = value } if options[:headers].present?

      # Evaluate the subject line as erb
      subject = ERB.new(options[:subject]).result(binding) if options[:subject].present?

      # Create the mail message
      email_hash = {}
      set_if_present(email_hash, :to, options[:to])
      set_if_present(email_hash, :from, options[:from])
      set_if_present(email_hash, :reply_to, options[:reply_to])
      set_if_present(email_hash, :subject, subject)

      # Eval the templates
      mail_message = mail(email_hash) do |format|
        format.text { render :inline => options[:text_erb] }
        format.html { render :inline => options[:html_erb] }
      end

      # Email service provider setup
      esp = options[:email_service_provider]
      mail_message.delivery_method.settings.merge!(
        {
          :address => esp.address,
          :user_name => esp.user_name,
          :password => esp.password,
          :port => esp.port,
          :authentication => esp.authentication,
          :enable_starttls_auto => esp.enable_starttls_auto,
          :domain => esp.domain
        })

      mail_message
    end

    protected

    def set_if_present(email_hash, key, value)
      email_hash[key] = value if value.present?
    end
  end
end
