module Facebase
  class Campaign < ActiveRecord::Base
    has_many :streams

    # Allows for a centralized configuration server
    if Facebase.config_database_uri.present?
      establish_connection(Facebase.config_database_uri)
    end


  end
end
