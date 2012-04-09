module Facebase
  class Stream < ActiveRecord::Base

    # Allows for a centralized configuration server
    if Facebase.config_database_uri.present?
      establish_connection(Facebase.config_database_uri)
    end

    belongs_to :campaign
    has_many :components
  end
end
