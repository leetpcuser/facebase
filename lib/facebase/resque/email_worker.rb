module Facebase
  class EmailWorker
    @queue = :email_worker

    def self.perform(profile_id, email_id)
      email = Facebase::Email.shard_for(profile_id).find(email_id)
      email.deliver
    end

  end
end
