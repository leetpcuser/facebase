module Facebase
  class Shard < ActiveRecord::Base

    # Allows for a centralized configuration server
    if Facebase.config_database_uri.present?
      establish_connection(Facebase.config_database_uri)
    end


    PRINCIPLE_PROFILE = "profile"
    PRINCIPLE_EMAIL = "email"

    before_create :setup_splits

    # Returns the index of this shard when sorted by id in a array of all shards
    def asc_index
      Facebase::Shard.order("id asc").all.each_with_index do |shard, index|
        return index if shard.id == self.id
      end
    end

    def components
      [PRINCIPLE_PROFILE, PRINCIPLE_EMAIL]
    end

    def connection_spec(include_database=true)
      connection_spec = {
        :adapter => self.adapter,
        :username => self.username,
        :password => self.password,

        :pool => self.pool,
        :reconnect => self.reconnect,
        :encoding => self.encoding,
      }

      # Sometimes you want the default connection without a database specified
      connection_spec[:database] = self.database if (include_database)

      if self.host.present?
        connection_spec[:host] = self.host
      else
        connection_spec[:socket] = self.socket
      end
      connection_spec
    end

    # Shards are [ self.auto_increment_start ... auto_increment_end)
    # Ie end exclusive. The end marks the beginning of a new shard
    def owns_principle_id?(principle_id)
      (self.auto_increment_start ... auto_increment_end).cover?(principle_id.to_i)
    end

    def auto_increment_end
      self.auto_increment_start + self.auto_increment_range
    end

    def initialize_shard
      if self.principle_model == PRINCIPLE_PROFILE
        #Set the autoincrement point
        Facebase::ShardInitializer.construct_class_set_for_shard(self)
        principle_class = Facebase::Profile.shard_for_shard_id(self.id)
        principle_class.connection.execute("ALTER TABLE #{principle_class.table_name} AUTO_INCREMENT = #{self.auto_increment_start}")
        self.update_attribute(:initialized, true)
      end
    end

    protected
    def setup_splits
      # If specified on creation don't override
      return if self.auto_increment_range.present? || self.auto_increment_start.present?

      shard_to_split = nil
      largest_shard_range = nil

      # Select the shard with the largest range left as the candidate to split
      self.class.where(:principle_model => self.principle_model).all.each do |shard|
        curr_range = shard.auto_increment_range
        if largest_shard_range.nil? || curr_range > largest_shard_range
          largest_shard_range = curr_range
          shard_to_split = shard
        end
      end

      # 18446744073709551615 = 2^64 - 1 (zero based unsigned integer)
      largest_shard_range = 18446744073709551615 if largest_shard_range.nil?

      # If there was a shard that we are splitting (the case for all
      # but the first allocation). Update its range appropriately otherwise
      # initialize the first shard with the full range
      if shard_to_split.present?
        first_half, second_half = split_range(largest_shard_range)
        shard_to_split.update_attribute(:auto_increment_range, first_half)
        self.auto_increment_range = second_half
        self.auto_increment_start = shard_to_split.auto_increment_start + first_half
      else
        self.auto_increment_range = largest_shard_range
        self.auto_increment_start = 1
      end
    end

    # Splits a range evenly accounting for odd and even splits
    def split_range(partition)
      half = partition/2
      second_half = partition/2
      second_half += 1 if partition.odd?
      return half, second_half
    end

  end
end
