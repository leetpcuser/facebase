module Facebase
  module ProfileModule
    extend ActiveSupport::Concern


    included do
      include Facebase::PrincipleModel

      # Once this module is included into a sharded base class it transforms
      # it into the activerecord class of its choosing. All associations and
      # table definitions should be declared here. Some of the rails magic breaks
      # because we are dynamically defining new classes right under rails nose

      serialize :interested_in, Array

      self.table_name = "facebase_profiles"

      # Define associations such that the class names follow convention
      has_one :contact, :class_name => "Facebase::Contact#{shard.asc_index}", :foreign_key => "profile_id"
      has_many :friends, :class_name => "Facebase::Friend#{shard.asc_index}", :foreign_key => "profile_id"

    end

    # Class methods go here
    module ClassMethods

      # Will try to use redis if we have redis setup as a index other wise
      # fallback to mysql evented solution
      def sharded_find_by_facebook_id

      end

      def sharded_find_or_create(facebook_id, user_hash)
        # TODO assuming a redis index (need to do the threaded lookup next)
        raise "No redis index, non index lookups not supported" unless Facebase.redis_index_uri

        profile = nil
        # First lock access to this particular facebook id
        Facebase::Redis::Lock.instance.lock(facebook_id) do
          profile_id = Facebase::Redis::Index.instance.redis.get(facebook_id)
          was_new_record = false

          # Find or create across our shards
          if profile_id.present?
            profile_class = Facebase::Profile.shard_for(profile_id)
            profile = profile_class.where(:id => profile_id).first
          end

          if profile.blank?
            profile_class = Facebase::Profile.balanced_shard
            profile = profile_class.create(:facebook_id => facebook_id)
            was_new_record = true
          end

          # Add some protection to ensure our index and table stay in sync
          profile_class.transaction do
            # Update the data appropriately
            profile.update_from_user_hash(user_hash)
            profile.save!

            # Update our index if its a new record (prevents index corruption)
            updated_index = Facebase::Redis::Index.instance.redis.set(facebook_id, profile.id)
            #raise "index wasn't updated with new profile, rolling back" if was_new_record && !updated_index
          end

        end
        return profile
      end

    end

    # apparently update is a reserved function
    def update_from_user_hash(user_hash)
      return if user_hash.blank?
      user_hash = user_hash.with_indifferent_access

      # Special function for parsing the ambiguous birthdays in facebook
      self.set_birthday_fb(user_hash['birthday']) if user_hash['birthday'].present?

      self.set_if_present('facebook_id', user_hash['id'])
      self.set_if_present('name', user_hash['name'])
      self.set_if_present('first_name', user_hash['first_name'])
      self.set_if_present('last_name', user_hash['last_name'])
      self.set_if_present('gender', user_hash['gender'])
      self.set_if_present('relationship_status', user_hash['relationship_status'])
      self.set_if_present('religion', user_hash['religion'])
      self.set_if_present('political', user_hash['political'])
      self.set_if_present('locale', user_hash['locale'])
      self.set_if_present('location', user_hash['location'].try(:[], 'name'))
      self.set_if_present('hometown', user_hash['hometown'].try(:[], 'name'))
    end

    def set_if_present(key, val)
      self.send(:write_attribute, key, val) if val.present?
    end


    # Returns the age in years of the person if known
    def age
      if birth_day_of_month.blank? || birth_month.blank? || birth_year.blank?
        return nil
      end

      dob = Chronic.parse("#{birth_day_of_month}/#{birth_month}/#{birth_year}")

      # Handles leap year correctly
      now = Time.now.utc.to_date
      now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    end


    # Returns the next birthday date
    def next_birthdate
      return nil if birth_day_of_month.blank? || birth_month.blank?
      year = Date.today.year
      dob = Chronic.parse("#{birth_day_of_month}/#{birth_month}/#{year}")
      mmdd = dob.strftime('%m%d')
      year += 1 if mmdd < Date.today.strftime('%m%d')
      mmdd = '0301' if mmdd == '0229' && !Date.parse("#{year}0101").leap?
      Date.parse("#{year}#{mmdd}")
    end

    # Finds the next half birthday coming up
    def next_half_birthdate
      return nil if next_birthdate.blank?
      half_birthday = next_birthdate.advance(:days => -182.5)
      if Time.now.to_date >= half_birthday
        half_birthday = next_birthdate.advance(:days => 182.5)
      end
      half_birthday
    end

    # Converts the birthday to a ruby datetime object
    def set_birthday_fb(fb_birthday_string)
      return if fb_birthday_string.blank?

      if fb_birthday_string.strip =~ /^\d{2}\/\d{2}\/\d{4}$/i
        birthday = Chronic.parse(fb_birthday_string)
        self.birth_day_of_month = birthday.day
        self.birth_month = birthday.month
        self.birth_year = birthday.year
      elsif fb_birthday_string.strip =~ /^\d{2}\/\d{2}$/i
        fb_birthday_string += "/2012" #append a year to help with parsing correctly
        birthday = Chronic.parse(fb_birthday_string)
        self.birth_day_of_month = birthday.day
        self.birth_month = birthday.month
      end
    end
  end
end
