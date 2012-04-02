module Facebase
  class Component < ActiveRecord::Base
    belongs_to :stream
    has_one :campaign, :through => :stream


    # Render with a mocked email
    def template_keys
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
          :text_erb => Facebase::Email.load_template(self.campaign.name, self.stream.name, self.name, "text.erb", true) ,
          :html_erb => Facebase::Email.load_template(self.campaign.name, self.stream.name, self.name, "html.erb", true),
          :email_service_provider => Facebase::EmailTemplate::MockEmailServiceProvider.new
        }
      )

      template_value_sniffer.template_keys
    end

  end
end
