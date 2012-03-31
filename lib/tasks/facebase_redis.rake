require 'resque/tasks'
require 'resque_scheduler/tasks'

namespace :facebase do

  namespace :redis do

    #desc "Construct the redis facebook_id -> profile_id index"
    #task :create_index => :environment do |t, args|
    #  raise "Facebase.redis_index_uri is blank" if Facebase.redis_index_uri.blank?
    #
    #  threads =[]
    #  num_batches = 20
    #  counter = 1
    #
    #  Facebase::Profile.on_all_in_batches(num_batches) do |shard_id, start, limit|
    #    sleep(3)
    #    puts "starting #{counter}"
    #    counter += 1
    #    threads << Thread.new do
    #      `RAILS_ENV=production rake facebase:[#{shard_id},#{start},#{limit}] --trace`
    #    end
    #  end
    #
    #  threads.each { |t| t.join }
    #end
    #
    #task :create_index_worker => :environment do |t, args|
    #
    #end


  end

  namespace :resque do

  end
end
