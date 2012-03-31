module Facebase
  class Importer

    # When importing users into facebase they can come from various places
    # and with different schema. Rather than writing one offs for parsing and
    # importing all these data sources in every application we will provide
    # a standard schema that you can feed facebase and it will do all the
    # import logic for you.
    #
    # The standardized full schema is below
    #
    # user_hash = {
    #   :facebook_id => 2341324124235,
    #   :email => "some@address.com",
    #   :name => "Full Name",
    #   :first_name => "First Name",
    #   :last_name => "Last Name",
    #   :gender => "male/female",
    #   :relationship_status => "Married",
    #   :religion => "Catholic",
    #   :political => "Democrat",
    #   :locale => "en_US",
    #   :hometown => "Manteca, California",
    #   :location => "San Francisco, California",
    #   :birthday => "02/23/1987 or 02/23",
    #   :friends => [
    #     {
    #       # Same schema as root user fields
    #       :facebook_id => 2341324124235,
    #       :email => "some@address.com",
    #       :name => "Full Name",
    #       :first_name => "First Name",
    #       :last_name => "Last Name",
    #       :gender => "male/female",
    #       :relationship_status => "Married",
    #       :religion => "Catholic",
    #       :political => "Democrat",
    #       :locale => "en_US",
    #       :hometown => "Manteca, California",
    #       :location => "San Francisco, California",
    #       :birthday => "02/23/1987 or 02/23",
    #
    #       # Friendlist support
    #       :is_close_friend => false,
    #       :is_acquaintance => false,
    #       :is_restricted => false,
    #       :is_school_friend => false,
    #       :is_coworker => false,
    #       :is_in_current_city => false,
    #       :is_family => false,
    #       :is_user_created => false,
    #
    #       # Social Algorithms
    #       :is_matching_last_name => false
    #
    #       # Derived Attributes
    #       :priority => 1-100
    #
    #     }
    #   ]
    # }

    # User hashes should conform to definition above, validation can be run
    # :never, :once, :all per batch.
    def import_users(user_hashes, validate=:once)

      # Provides easy ways to perform validation. By default we do a single
      # user hash worth of validation for some protection without huge hit
      # in cpu performance
      if validate == :once
        validate_user_schema(user_hashes.first)
        user_hashes.each { |user_hash| import_user(user_hash, false) }
      elsif validate == :never
        user_hashes.each { |user_hash| import_user(user_hash, false) }
      elsif validate == :all
        user_hashes.each { |user_hash| import_user(user_hash, true) }
      end
    end


    # Imports a user hash constructing contacts, profiles and friends as
    # necessary. All records are found or created and updated using the
    # user_hash schema above
    def import_user(user_hash, validate=false)
      return if user_hash.blank?

      # Perform validation if requested (before we split the hash)
      validate_user_schema(user_hash) if validate

      # Break down users and their friends into two variables
      user_hash = user_hash.with_indifferent_access
      friends = user_hash.delete(:friends)

      # Import the users profile
      facebook_id = user_hash[:facebook_id]
      profile = Facebase::Profile.sharded_find_or_create(facebook_id, user_hash)

      # Import the contact
      import_contact(profile, user_hash)

      # Import the friends
      import_friends(profile, friends)

      # Return the principle model
      return profile
    end


    # ------------------------------------------- Validation
    # Helpful validation methods that check to make sure your parsing agent
    # is passing data correctly
    def validate_user_schema(user_hash)
      user_hash = user_hash.with_indifferent_access
      valid_keys = [:facebook_id, :email, :name, :first_name, :last_name,
                    :gender, :relationship_status, :religion, :political,
                    :locale, :hometown, :location, :birthday, :friends]

      user_hash.keys.each do |key|
        raise "invalid user_hash #{key} not in valid keys" unless valid_keys.include?(key.intern)
      end


      if user_hash[:friends].present?
        user_hash[:friends].each { |friend_hash| validate_friend_schema(friend_hash) }
      end
    end

    def validate_friend_schema(friend_hash)
      friend_hash = friend_hash.with_indifferent_access

      valid_keys = [:facebook_id, :email, :name, :first_name, :last_name,
                    :gender, :relationship_status, :religion, :political,
                    :locale, :hometown, :location, :birthday]

      friend_hash.keys.each do |key|
        raise "invalid friend_hash #{key} not in valid keys" unless valid_keys.include?(key.intern)
      end
    end


    protected

    def import_friends(profile, friends)
      return if friends.blank?

      friends.each do |friend_hash|
        friend_hash = friend_hash.with_indifferent_access

        # Lookup the facebook_id
        facebook_id = friend_hash[:facebook_id]
        next if facebook_id.blank?

        # Create the friend profile
        friend_profile = Facebase::Profile.sharded_find_or_create(facebook_id, friend_hash)

        # Create the friend join record
        friend_record = profile.friends.find_or_create_by_friends_profile_id(:friends_profile_id => friend_profile.id)
        friend_record.update_from_friend_hash(friend_hash)
        friend_record.save!
      end
    end

    def import_contact(profile, user_hash)
      new_email = user_hash[:email]
      if new_email.present?
        # Always start with the contact. We should only have one contact per
        # email-phone-profile_id/facebook_id. Look the contact up on the
        # unique constraint and update its profile. Never the otherway around.
        #
        # Here is why: Imagine the following scenario
        # ProfileA => EmailA (Installed your app)
        # ProfileB => EmailB
        #
        # later... they switch email addresses and then install with other profile
        # ProfileA => EmailB (Installed your app)
        # ProfileB => EmailA (Just now installed your app)
        #
        # If you lookup profile A going to the contact you will get the wrong email
        # TODO build a dedup task to be run every so often for this rare edge case
        #

        contact_class = Facebase::Contact.shard_for(profile.id)
        contact = contact_class.where(:profile_id => profile.id).first
        if contact.blank?
          contact = contact_class.new
          contact.profile_id = profile.id
        end
        contact.update_from_user_hash(user_hash)
        contact.save!
      end
    end

  end
end
