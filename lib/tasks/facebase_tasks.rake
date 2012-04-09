namespace :facebase do
  namespace :db do

    desc "Create shard databases"
    task :create => :environment do
      shards = Facebase::Shard.where(
        :principle_model => Facebase::Shard::PRINCIPLE_PROFILE
      ).all.to_a

      shards.each do |shard|
        fork do
          ActiveRecord::Base.establish_connection(shard.connection_spec(false))
          ActiveRecord::Base.connection.execute("CREATE DATABASE #{shard.database}")
        end
      end
      Process.waitall
    end

    desc "Drop shard databases"
    task :drop => :environment do
      shards = Facebase::Shard.where(
        :principle_model => Facebase::Shard::PRINCIPLE_PROFILE
      ).all.to_a

      shards.each do |shard|
        fork do
          ActiveRecord::Base.establish_connection(shard.connection_spec(false))
          ActiveRecord::Base.connection.execute("DROP DATABASE #{shard.database}")
        end
      end
      Process.waitall
    end

    desc "Migrate all profile shards to latest"
    task :migrate => :environment do
      shards = Facebase::Shard.where(
        :principle_model => Facebase::Shard::PRINCIPLE_PROFILE
      ).all.to_a

      shards.each do |shard|
        fork do
          _migrate('db/shard_migrations', shard.connection_spec)
        end
      end
      Process.waitall
    end

    desc "Initialize New Shards"
    task :initialize_shards => :environment do
      shards = Facebase::Shard.where(
        :principle_model => Facebase::Shard::PRINCIPLE_PROFILE,
        :initialized => false
      ).all.to_a

      shards.each { |s| s.initialize_shard }
    end

    namespace :migrate do
      desc "Drops, creates, migrates, and initializes all profile shards"
      task :reset => :environment do
        shards = Facebase::Shard.where(
          :principle_model => Facebase::Shard::PRINCIPLE_PROFILE
        ).all.to_a


        shards.each do |shard|
          fork do
            ActiveRecord::Base.establish_connection(shard.connection_spec)
            ActiveRecord::Base.connection.execute("DROP DATABASE #{shard.database}")
            ActiveRecord::Base.connection.execute("CREATE DATABASE #{shard.database}")
            _migrate('db/shard_migrations', shard.connection_spec)
          end
        end
        Process.waitall
      end
    end

    # ------------------------------------------- Helpers
    # Helper for performing a migrations
    def _migrate(migration_path, connection_spec)
      ActiveRecord::Base.establish_connection(connection_spec)
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate([migration_path], ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
        ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
      end
    end

  end
end
