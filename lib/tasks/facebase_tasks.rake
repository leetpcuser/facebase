namespace :facebase do

  namespace :emails do
    desc "Sends scheduled emails for a given shard_id"
    task :shard_send_scheduled, [:shard_id] => :environment do |t, args|
      log = Logger.new(STDOUT)
      log.level = Logger::DEBUG

      # Create 1 less than the size of the connection pool for the shards
      # default is 5. Keep the queue to twice the size of active threads
      wq = WorkQueue.new(4, 8)

      shard_class = Facebase::Email.shard_for_shard_id(args.shard_id.to_i)

      # Find all upcoming unsent, nonfailed emails queue them up 1000 at a time
      # (default for find_in_batches) and thread the sends. Add rescue blocks
      # under each iteration to prevent mass failure. Log the errors.
      shard_class.where(['schedule_at <= ?', Time.now]).
        where(:sent => false, :failed => false).
        find_in_batches do |batched_data|
        begin
          wq.enqueue_b(batched_data) do |batched_data_t|
            batched_data_t.each do |email|
              begin
                next if email.sent || email.failed
                email.deliver
                log.debug(email.to)
              rescue => e
                log.debug(e.message)
                log.debug(e.backtrace)
              end
            end
          end
        rescue => e
          log.debug(e.message)
          log.debug(e.backtrace)
        end
      end

      wq.join
    end
  end

  namespace :analytics do
    desc "When passed a valid shard index it updates analytics from that shard"
    task :update, [:shard_index] => :environment do |t, args|
      Facebase::EmailAction.update_segmented_analytics(args.shard_index.to_i)
    end
  end


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
