module Facebase
  class Engine < ::Rails::Engine
    isolate_namespace Facebase

    config.after_initialize do
      # Initialize the dynamic sharded classes
      Facebase::ShardInitializer.initialize_shard_classes

      # If we have a resque uri bootstrap resque
      Resque.redis = Facebase.redis_resque_uri if Facebase.redis_resque_uri.present?
    end

  end
end
