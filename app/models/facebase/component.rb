module Facebase
  class Component < ActiveRecord::Base

    # Allows for a centralized configuration server
    if Facebase.config_database_uri.present?
      establish_connection(Facebase.config_database_uri)
    end


    belongs_to :stream
    has_one :campaign, :through => :stream


    # ------------------------------------------- Analytics
    def opens
      total = 0
      Facebase::Email.on_each_shard do |shard_class|
        shard_class.where(:campaign => self.campaign.name,
                          :stream => self.stream.name,
                          :component => self.name).find_each do |email|
          total += email.email_actions.where(:action_type => MAIL_SPY_OPEN).count
        end
      end

      total
    end


    # Sniffs the template keys from the template robustly. On error blank array
    # is passed back
    def template_keys
      keys = []
      begin
        template_value_sniffer = Facebase::EmailTemplate::TemplateValuesSniffer.new
        Facebase::CoreMailer.template(
          {
            :headers => {},
            :template_values => template_value_sniffer,
            :to => "to@someemail.com",
            :from => "from@someemail.com",
            :reply_to => "reply_to@someemail.com",
            :subject => "test_subject",
            :composite_id => "testCompositeId",
            :text_erb => Facebase::Email.load_template(self.campaign.name, self.stream.name, self.name, "text.erb", true),
            :html_erb => Facebase::Email.load_template(self.campaign.name, self.stream.name, self.name, "html.erb", true),
            :email_service_provider => Facebase::EmailTemplate::MockEmailServiceProvider.new
          }
        )

        keys = template_value_sniffer.template_keys
      rescue => e
        pp "Error: Couldn't sniff template keys"
        pp e.message
        pp e.backtrace
      end

      keys
    end


    def save_template_content(template_content)
      raise "No aws_campaign_bucket_set" if Facebase.aws_campaign_bucket.strip.blank?

      # Load the object from s3
      s3 = AWS::S3.new(:access_key_id => Facebase.aws_access_key_id,
                       :secret_access_key => Facebase.aws_secret_access_key)
      campaign_bucket = s3.buckets[Facebase.aws_campaign_bucket]
      campaign_bucket = buckets.create(Facebase.aws_campaign_bucket) unless campaign_bucket.exists?

      object = campaign_bucket.objects[s3_path]
      raise "no object found at path:  #{s3_path}" unless object.exists?

      # Write the object
      object.write(template_content)
    end

    def s3_path
      "#{self.campaign.name}/#{self.stream.name}/#{self.name}.#{self.suffix}"
    end

  end
end
