# Class implements a high concurrency lock store that
module Facebase
  module Redis
    class Index
      include Singleton

      attr_reader :redis

      def initialize
        @redis = ::Redis.connect(:url => Facebase.redis_index_uri)
      end

    end
  end
end
