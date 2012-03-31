module Facebase

  # Raised when a connection could not be obtained within the connection
  # acquisition timeout period.
  class ShardKeyChangeException < RuntimeError
  end

  class ShardKeyMissingException < RuntimeError
  end

  # Principle model is the model that the entire database is keyed against for
  # sharding
  module PrincipleModel
    extend ActiveSupport::Concern

    # ------------------------------------------- SHARD KEY PROTECTION

    # Saving (updating records) should be allowed so long as the shard key
    # didn't change unless we explicitly want that
    def update_attribute(name, value)
      if name.downcase == "id"
        raise Facebase::ShardKeyChangeException
      end
      super(name, value)
    end

    def update_attributes(attributes)
      if attributes[:id].present?
        raise Facebase::ShardKeyChangeException
      end
      super(attributes)
    end

    def update_attributes!(attributes)
      if attributes[:id].present?
        raise Facebase::ShardKeyChangeException
      end
      super(attributes)
    end

    def save
      if id_changed? && !new_record?
        raise Facebase::ShardKeyChangeException
      end
      super
    end

    def save!
      if id_changed? && !new_record?
        raise Facebase::ShardKeyChangeException
      end
      super
    end


  end
end
