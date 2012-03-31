module Facebase
  module EmailActionModule
    extend ActiveSupport::Concern

    # Generic Events
    ACTION_TYPE_OPEN = "open"
    ACTION_TYPE_CLICK = "click"
    ACTION_TYPE_BOUNCE = "bounce"
    ACTION_TYPE_UNSUBSCRIBE = "unsubscribe"
    ACTION_TYPE_SPAM = "spam"
    ACTION_TYPE_DROPPED = "dropped"
    ACTION_TYPE_DELIVERED = "delivered"

    # MailSpy native events
    MAIL_SPY_PREFIX = "mailspy"
    MAIL_SPY_OPEN = "#{MAIL_SPY_PREFIX}_#{ACTION_TYPE_OPEN}"
    MAIL_SPY_CLICK = "#{MAIL_SPY_PREFIX}_#{ACTION_TYPE_CLICK}"
    #MAIL_SPY_BOUNCE = "#{MAIL_SPY_PREFIX}_#{ACTION_TYPE_BOUNCE}"
    MAIL_SPY_UNSUBSCRIBE = "#{MAIL_SPY_PREFIX}_#{ACTION_TYPE_UNSUBSCRIBE}"
    #MAIL_SPY_SPAM = "#{MAIL_SPY_PREFIX}_#{ACTION_TYPE_SPAM}"
    #MAIL_SPY_DROPPED = "#{MAIL_SPY_PREFIX}_#{ACTION_TYPE_DROPPED}"
    #MAIL_SPY_DELIVERED = "#{MAIL_SPY_PREFIX}_#{ACTION_TYPE_DELIVERED}"

    # Sendgrid specific events
    SENDGRID_PREFIX = "sendgrid"
    SENDGRID_OPEN = "#{SENDGRID_PREFIX}_#{ACTION_TYPE_OPEN}"
    SENDGRID_CLICK = "#{SENDGRID_PREFIX}_#{ACTION_TYPE_CLICK}"
    SENDGRID_BOUNCE = "#{SENDGRID_PREFIX}_#{ACTION_TYPE_BOUNCE}"
    SENDGRID_UNSUBSCRIBE = "#{SENDGRID_PREFIX}_#{ACTION_TYPE_UNSUBSCRIBE}"
    SENDGRID_SPAM = "#{SENDGRID_PREFIX}_#{ACTION_TYPE_SPAM}"
    SENDGRID_DROPPED = "#{SENDGRID_PREFIX}_#{ACTION_TYPE_DROPPED}"
    SENDGRID_DELIVERED = "#{SENDGRID_PREFIX}_#{ACTION_TYPE_DELIVERED}"
    SENDGRID_PROCESSED = "#{SENDGRID_PREFIX}_processed"
    SENDGRID_DEFERRED = "#{SENDGRID_PREFIX}_deferred"


    included do
      serialize :details, Hash

      self.table_name = "facebase_email_actions"

      belongs_to :email, :class_name => "Facebase::Email#{shard.asc_index}", :foreign_key => "email_id"
    end
  end
end


