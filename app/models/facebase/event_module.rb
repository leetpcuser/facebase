module Facebase
  module EventModule
    extend ActiveSupport::Concern

    BIRTHDAY = "birthday"
    HALF_BIRTHDAY = "half_birthday"
    ANNIVERSARY = "anniversary"

    included do

      serialize :details, Hash


      self.table_name = "facebase_events"

      belongs_to :contact, :class_name => "Facebase::Contact#{shard.asc_index}", :foreign_key => "contact_id"
      #belongs_to :profile # have to write a sharded accessor pattern for profile

    end

    module ClassMethods

      # Basic method for boot strapping at least 100 events per person
      def construct_events

      end

    end


  end
end
