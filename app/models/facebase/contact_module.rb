module Facebase
  module ContactModule
    extend ActiveSupport::Concern

    included do

      self.table_name = "facebase_contacts"

      has_many :events, :class_name => "Facebase::Event#{shard.asc_index}", :foreign_key => "contact_id"
      has_many :emails, :class_name => "Facebase::Email#{shard.asc_index}", :foreign_key => "contact_id"

      # This will actually work without problem because all the profiles for a
      # contact will be on the same shard
      belongs_to :profile, :class_name => "Facebase::Profile#{shard.asc_index}", :foreign_key => "profile_id"
      has_many :friends, :through => :profile

    end


    def email_address=(val)
      # Try to standardize the email addresses
      write_attribute(:email_address, std_email_address(val))
    end


    def update_from_user_hash(user_hash)
      return if user_hash.blank?
      user_hash = user_hash.with_indifferent_access

      set_if_present('facebook_id', user_hash['facebook_id'])
      set_if_present('email_address', std_email_address(user_hash['email']))
      set_if_present('phone', std_email_address(user_hash['phone']))
    end

    protected

    def set_if_present(key, val)
      self.send(:write_attribute, key, val) if val.present?
    end


    # Tries to remove the standard errors with email address entry
    def std_email_address(email_address)
      email_address.try(:strip).try(:downcase)
    end
  end
end
