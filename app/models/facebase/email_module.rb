module Facebase
  module EmailModule
    extend ActiveSupport::Concern


    included do
      # Once this module is included into a sharded base class it transforms
      # it into the activerecord class of its choosing. All associations and
      # table definitions should be declared here. Some of the rails magic breaks
      # because we are dynamically defining new classes right under rails nose

      serialize :headers, JSON
      serialize :template_values, JSON

      self.table_name = "facebase_emails"

      # Since we don't specify the class it hits the primary db (aka not sharded)
      belongs_to :email_service_provider

      #Sharded associations
      belongs_to :contact, :class_name => "Facebase::Contact#{shard.asc_index}", :foreign_key => "contact_id"
      has_many :email_actions, :class_name => "Facebase::EmailAction#{shard.asc_index}", :foreign_key => "email_id"

      validates_presence_of :campaign, :stream, :component, :schedule_at, :subject,
                            :from, :reply_to, :contact_id


      validates_presence_of :email_service_provider_id

      # Allows a blank hash to pass
      validates_presence_of :template_values, :unless => Proc.new { |email| email.template_values.kind_of?(Hash) }

      before_save :infer_to_address
      before_create :auto_google_analytics
      before_create :ensure_templates
      after_create :create_sendgrid_header

      class_attribute :template_cache

    end

    # Class methods go here
    module ClassMethods

      # Loads a template file from s3, on error returns the error message
      def load_template(campaign, stream, component, suffix="html.erb", force_refresh=false)
        if Facebase.aws_campaign_bucket.strip.blank?
          message = "No aws_campaign_bucket_set"
          pp message
          return message
        end

        # Check the cache using our convention
        path = self.computed_s3_path(campaign, stream, component, suffix)
        @template_cache ||= {}
        return @template_cache[path] if @template_cache[path].present? && !force_refresh

        # Load the object from s3
        s3 = AWS::S3.new(:access_key_id => Facebase.aws_access_key_id,
                         :secret_access_key => Facebase.aws_secret_access_key)
        campaign_bucket = s3.buckets[Facebase.aws_campaign_bucket]
        campaign_bucket = buckets.create(Facebase.aws_campaign_bucket) unless campaign_bucket.exists?
        object = campaign_bucket.objects[path]

        # Return the error message
        unless object.exists?
          message = "no object found at path:  #{path}"
          pp message
          return message
        end

        # Read and return
        @template_cache[path] = (object.read || "")
        return @template_cache[path]
      end


      def computed_s3_path(campaign, stream, component, suffix)
        "#{campaign}/#{stream}/#{component}.#{suffix}"
      end

    end


    # ------------------------------------------- ACCESSORS
    def template_values
      self.read_attribute(:template_values).try(:with_indifferent_access)
    end

    # Used to identify the email among shards, also used in sendgrid tracking
    def composite_id
      raise "Composite id is only valid on existing emails" if new_record? || self.id.blank?
      profile_id = self.contact.profile.id

      # This id is tightly coupled with the sendgrid controller. Make sure to
      # reference it when changing code here
      "#{profile_id}-#{self.id}"
    end


    # ------------------------------------------- DELIVERY
    def deliver(force=false)
      begin
        # Protect against poor sending habits
        return if ((self.sent || self.failed) && !force)
        Facebase::CoreMailer.template_from_email(self).deliver
        self.update_attribute(:sent, true)
        self.contact.update_attribute(:last_contacted_at, Time.now)
      rescue => e
        pp e.message
        pp e.backtrace
        self.failed = true
        self.error_message = e.try(:message)
        self.error_backtrace = e.try(:backtrace)
        self.save!
      end
    end

    # TODO integrate the facebook apps into facebase email service providers
    def facebook_deliver(app_access_tokens, force=false)
      # Protect against poor sending habits
      return if ((self.sent || self.failed) && !force)

      index = 0
      begin
        facebook_id = self.contact.profile.facebook_id

        api = Koala::Facebook::API.new(app_access_tokens[index])
        api.rest_call("notifications.sendEmail", {
          :recipients => [facebook_id],
          :subject => self.subject,
          :fbml => self.parsed_html_content.squeeze(" ")
        })
        self.update_attribute(:sent, true)
        self.contact.update_attribute(:last_contacted_at, Time.now)
      rescue Exception => e
        if app_access_tokens.present? && app_access_tokens.size > index
          index += 1
          retry
        end
        pp e.message
        pp e.backtrace
        self.failed = true
        self.error_message = e.try(:message)
        self.error_backtrace = e.try(:backtrace)
        self.save!
      end


    end

    # ------------------------------------------- S3 TEMPLATES

    # Great for debugging emails
    def parsed_html_content
      return Facebase::CoreMailer.template_from_email(self).html_part.body.to_s
    end

    def parsed_text_content
      return Facebase::CoreMailer.template_from_email(self).text_part.body.to_s
    end

    def html_erb(force_refresh=false)
      self.class.load_template(self.campaign, self.stream, self.component, "html.erb", force_refresh)
    end

    def text_erb(force_refresh=false)
      self.class.load_template(self.campaign, self.stream, self.component, "text.erb", force_refresh)
    end


    # ------------------------------------------- AR CALLBACKS

    def infer_to_address
      self.to ||= self.contact.email_address
    end

    def create_sendgrid_header
      # Enable sendgrid specific enhancements
      # Must happen after the email has been saved for the id
      if self.email_service_provider.enable_sendgrid_tracking && self.headers.blank?

        # Generate the header and set sendgrid category
        header = Facebase::Sendgrid::SmtpApiHeader.new
        header.setCategory("#{self.campaign}-#{self.stream}-#{self.component}")
        header.setUniqueArgs({:com_id => self.composite_id})

        # Will force another round of callbacks but will get the serialization right
        self.headers = {'X-SMTPAPI' => header.asJSON}.merge(self.headers)
        self.save!
      end
    end

    def ensure_templates
      # Ensure we have the template for the email on s3
      raise "Missing html template" unless self.html_erb.present?
      raise "Missing text template" unless self.text_erb.present?
    end

    def auto_google_analytics
      # Google Analytics support for automatic population of utm_tokens
      if self.email_service_provider.enable_auto_google_analytics
        self.utm_source ||= 'mailspy'
        self.utm_medium ||= 'email'
        self.utm_campaign ||= self.campaign
        self.utm_term ||= self.stream
        self.utm_content ||= self.component
      end
    end

  end
end
