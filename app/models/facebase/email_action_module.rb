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

    module ClassMethods
      # ----------------------------------------- Analytics

      # Method used email actions to update our analytics for campaigns, streams
      # and components. Since this may take time we pass shard_id to allow
      # multiple computers to handle each process.
      def update_segmented_analytics(shard_id)
        shard_class = Facebase::Email.shard_for_shard_id(shard_id)
        shard_class.where(:is_analyzed => false).includes(:email).find_each do |email_action|
          update_segment(email_action)
        end
      end

      protected

      # Does the heavy lifting, counting, searching and saving all related records
      def update_segment(email_action)
        # Lookup all records
        email = email_action.email
        return if email.blank?
        campaign = Facebase::Campaign.where(:name => email.campaign).first
        return if campaign.blank?
        stream = campaign.streams.where(:name => email.stream).first
        return if stream.blank?
        components = stream.components.where(:name => email.component).all
        return if components.blank?

        # Count the actions we analyze
        opens = 0
        clicks = 0
        unsubscribes = 0
        spams = 0
        delivered = 0

        if email_action.action_type.include? ACTION_TYPE_OPEN
          opens += email_action.count || 1
        elsif email_action.action_type.include? ACTION_TYPE_CLICK
          clicks += email_action.count || 1
        elsif email_action.action_type.include? ACTION_TYPE_UNSUBSCRIBE
          unsubscribes += email_action.count || 1
        elsif email_action.action_type.include? ACTION_TYPE_SPAM
          spams += email_action.count || 1
        elsif email_action.action_type.include? ACTION_TYPE_DELIVERED
          delivered += email_action.count || 1
        end

        email_action.update_attribute(:is_analyzed, true)

        # Create a list of models to update
        config_models = []
        config_models << campaign
        config_models << stream
        config_models += components

        # Rails transactions aren't functional across database connections
        # so nesting the email_action update call in the following transaction
        # won't do anything
        Facebase::Campaign.transaction do

          # All analytics models currently have the same schema.
          config_models.each do |model|
            model.opens += opens
            model.clicks += clicks
            model.unsubscribes += unsubscribes
            model.spams += spams
            model.delivered += delivered
            model.save!
          end
        end
      end
    end

  end
end


