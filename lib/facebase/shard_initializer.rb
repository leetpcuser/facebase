module Facebase
  class ShardInitializer
    def self.initialize_shard_classes
      if Facebase::Shard.table_exists?
        shards = Facebase::Shard.where(
          :principle_model => Facebase::Shard::PRINCIPLE_PROFILE,
          :initialized => true
        ).all

        pp "Please install shards before running in production" if shards.blank?
        shards.each { |shard| construct_class_set_for_shard(shard) }
      else
        # Warning is all i can do as we need to run this at startup for migrations
        pp "Shard table not present, skipping sharding"
      end
    end

    # Allows shards class sets to be contructed during the initialization process
    def self.construct_class_set_for_shard(shard)
      sharded_base = construct_sharded_base(shard)
      construct_sharded_tree(sharded_base)
      sharded_base
    end

    protected

    # Constructs a abstract base class that will hold the connection pools the
    # given shards models.
    def self.construct_sharded_base(shard)
      the_klass = Class.new(ActiveRecord::Base) do
        self.abstract_class = true
        # When a shard class is instantiated it is given a Facebase::Shard instance
        # that defines which connection it will be using. These methods help
        # identify the shard when used in the parent shardable classes
        class_attribute :shard
      end

      # Order here is really important, the klass must have the shard before
      # registering, and the connection must be established after registration!
      the_klass.shard = shard
      register_sharded_class(base_class_name(self), the_klass)
      the_klass.establish_connection(shard.connection_spec)

      the_klass
    end

    # Given a base class with a connection to a given shards node we construct
    # a tree of classes that inherit the connection pool to their shard
    def self.construct_sharded_tree(sharded_base)

      sharded_model_modules = [
        Facebase::ProfileModule,
        Facebase::FriendModule,
        Facebase::EmailModule,
        Facebase::EmailActionModule,
        Facebase::EventModule,
        Facebase::ContactModule
      ]

      sharded_model_modules.each do |model_module|
        # Create the sharded subclass and inject its model definition
        sharded_model = Class.new(sharded_base) { include model_module }

        # Register the class in the facebase namespace
        register_sharded_class(base_class_name(model_module), sharded_model)

        # Construct the manager class for all sharded subclasses
        manager = sharded_model_manager(model_module)
        manager.add_cached_shard_class(sharded_model)

        # Extend the manager with the class methods for the module
        if model_module.const_defined?("ClassMethods", false)
          manager.extend "#{model_module.name}::ClassMethods".constantize
        end
      end
    end

    def self.sharded_model_manager(model_module)
      constant_name = base_class_name(model_module)

      if class_exists?(constant_name)
        return Facebase.const_get(constant_name)
      else
        the_klass = Class.new { include Facebase::ShardManagement }
        Facebase.const_set(constant_name, the_klass)
        return the_klass
      end
    end

    def self.register_sharded_class(base_class_name, sharded_class_instance)
      constant_name = "#{base_class_name}#{sharded_class_instance.shard.asc_index}"
      Facebase.const_set(constant_name, sharded_class_instance)
      constant_name
    end

    def self.class_exists?(class_name)
      klass = Facebase.const_get(class_name)
      return klass.is_a?(Class)
    rescue NameError
      return false
    end

    # Returns a string that is the name of the base class for a model module
    # ex: Facebase::ProfileModule => Profile
    # ex: Facebase::ShardInitializer => ShardInitializer
    def self.base_class_name(klass)
      constant_name = klass.name.split("::").last
      constant_name.gsub("Module", "")
    end

  end
end
