module Facebase
  module ShardManagement
    extend ActiveSupport::Concern

    module ClassMethods

      # Allows the principle to add shard class instances to
      def add_cached_shard_class(shard_class)
        @_ar_cached_shard_classes ||=[]
        @_ar_cached_shard_classes << shard_class
      end

      # Loops through all shard classes
      def on_each_shard(&block)
        @_ar_cached_shard_classes.each do |shard_class|
          block.call(shard_class)
        end
      end

      # Provides a fast scalable way to loop through shards in batches for
      # high concurrency. Num batches will be the number of batches each shard
      # is broken down into. So if you have 8 shards and 10 num_batches then you
      # will have 80 calls with parallel cuts through all records
      #
      # Expects a block to take shard_id, a starting index, and a limit.
      #
      # This function pairs well with rails' find_in_batches.
      def on_all_in_batches(num_batches, &block)
        on_each_shard do |shard_class|
          next if shard_class.first.blank? # Skip if shard is empty

          # Current shard
          shard = shard_class.shard

          # Max and starting point
          max = shard_class.order("id desc").first.id
          start = shard_class.order("id asc").first.id
          max_batch_index = num_batches - 1

          # Increment value
          batch_size = (max - start) / num_batches

          # Find what is left for the last batch
          # (in case num_batches didn't divide evenly)
          last_batch_size = (max - start) - (max_batch_index - 1) * batch_size

          # "times" method always starts with 0 so index will be correct
          num_batches.times do |index|

            if index == max_batch_index
              block.call(shard.id, start, last_batch_size)
            else
              block.call(shard.id, start, batch_size)
            end

            start += batch_size
          end
        end
      end


      # Balanced shard is a naive approach to balancing that attempts to
      # slowly correct shard counts without exclusively hitting the laggers
      # The algorithm below favors 10% laggers in the principle model count
      # and half the time only selects from the lagger shards. If the cluster
      # is well balanced and no shards are 10% behind the leader then its just
      # a random distribution
      def balanced_shard
        # TODO Disabling balanced shard until we rework counts to go faster
        #@_ar_sharded_balance_count ||= 0
        #@_ar_sharded_semaphore ||= Mutex.new
        #returning_shard = nil
        #
        ## Do a thread sync on the balancing agent so we don't rebalance while
        ## we are retrieving a shard class
        #@_ar_sharded_semaphore.synchronize do
        #
        #  # Rebalance every 10000 lookups
        #  if @_ar_sharded_balance_count.to_i > 10000
        #    @_ar_sharded_laggers = []
        #
        #    # Find the leaders count
        #    # TODO this is a bottle neck on large sets.
        #    max_count = 0
        #    @_ar_cached_shard_classes.each do |shard_class|
        #      curr_count = shard_class.count
        #      max_count = curr_count if curr_count > max_count
        #    end
        #
        #    # Designate the laggers
        #    # You are a lagger if you are 10% behind the leader
        #    @_ar_cached_shard_classes.each do |shard_class|
        #      curr_count = shard_class.count
        #      @_ar_sharded_laggers << shard_class if (max_count * 0.9) > curr_count
        #    end
        #
        #    #After rebalancing reset the counter
        #    @_ar_sharded_balance_count = 0
        #  end
        #
        #  # If we have laggers favor them half the time to have them catch up
        #  if @_ar_sharded_laggers.present? && rand >= 0.5
        #    returning_shard = @_ar_sharded_laggers.sample
        #  else
        #    returning_shard = random_shard
        #  end
        #
        #  @_ar_sharded_balance_count += 1
        #end
        #
        #returning_shard
        @_ar_cached_shard_classes.sample
      end

      def random_shard
        @_ar_cached_shard_classes.sample
      end

      def shard_for_shard_id(shard_id)
        @_ar_cached_shard_classes.detect do |shard_class|
          # IT IS ABSOLUTELY IMPERATIVE THAT THIS ID IS a integer!
          shard_class.shard.id == shard_id.to_i
        end
      end

      # Returns a class that has a connection established to the connection spec
      # for the given random number
      def shard_for(principle_id)
        @_ar_cached_shard_classes.detect do |shard_class|
          # IT IS ABSOLUTELY IMPERATIVE THAT THIS ID IS a integer!
          shard_class.shard.owns_principle_id?(principle_id.to_i)
        end
      end

    end
  end
end
