module Facebase
  class ApplicationController < ActionController::Base

    #Authenticates users if you have setup the initializer correctly
    def authenticate_admin!
      if Facebase.password && Facebase.username
        authenticate_or_request_with_http_basic do |username, password|
          username == Virality.username && password == Virality.password
        end
      end
    end
  end
end
