module Facebase
  class EmailServiceProvider < ActiveRecord::Base

    # Allows for a centralized configuration server
    if Facebase.config_database_uri.present?
      establish_connection(Facebase.config_database_uri)
    end

    has_many :emails
  end
end
