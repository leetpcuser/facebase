# Class implements a high concurrency lock store that
module Facebase
  module Redis
    class Lock
      include Singleton

      attr_reader :redis

      def initialize
        @redis = ::Redis.connect(:url => Facebase.redis_lock_uri)
      end


      def lock(key, retry_limit = 50, &block)
        lock_name = "lock.#{key}"
        begin
          # Keep trying until the retry count is exceeded or we get the lock
          retry_count = 0
          while !@redis.setnx(lock_name, Time.now.to_s)
            return if retry_count >= retry_limit
            sleep(1)
            retry_count += 1
          end

          block.call if block_given?

        ensure
          # Make sure we release the lock when we are done
          @redis.del(lock_name)
        end
      end

    end
  end
end
