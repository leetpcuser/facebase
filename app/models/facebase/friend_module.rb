module Facebase
  module FriendModule
    extend ActiveSupport::Concern

    included do
      # Once this module is included into a sharded base class it transforms
      # it into the activerecord class of its choosing. All associations and
      # table definitions should be declared here. Some of the rails magic breaks
      # because we are dynamically defining new classes right under rails nose

      serialize :interested_in, Array

      self.table_name = "facebase_friends"

      belongs_to :profile, :class_name => "Facebase::Profile#{shard.asc_index}", :foreign_key => "profile_id"
      #belongs_to :friend_profiles # have to write a sharded accessor pattern
    end

    # Class methods go here
    module ClassMethods
    end

    # Update is a reserved function, updates record with a friend_hash
    def update_from_friend_hash(friend_hash)
      return if friend_hash.blank?
      friend_hash = friend_hash.with_indifferent_access

      set_if_present(:facebook_id, friend_hash[:facebook_id])
      set_if_present(:is_matching_last_name, friend_hash[:is_matching_last_name])
      set_if_present(:priority, friend_hash[:priority])

      # Friendlist attributes dont need to be set if present
      self.is_family = friend_hash[:is_family].present?
      self.is_close_friend = friend_hash[:is_close_friend].present?
      self.is_user_created = friend_hash[:is_user_created].present?
      self.is_restricted = friend_hash[:is_restricted].present?
      self.is_acquaintance = friend_hash[:is_acquaintance].present?
      self.is_school_friend = friend_hash[:is_school_friend].present?
      self.is_coworker = friend_hash[:is_coworker].present?
      self.is_in_current_city = friend_hash[:is_in_current_city].present?
    end

    protected

    def set_if_present(key, val)
      self.send(:write_attribute, key, val) if val.present?
    end


  end
end
