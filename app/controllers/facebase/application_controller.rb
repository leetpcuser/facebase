module Facebase
  class ApplicationController < ActionController::Base

    before_filter :set_admin_session

    #Authenticates users if you have setup the initializer correctly
    def authenticate_admin!
      if Facebase.password && Facebase.username
        authenticate_or_request_with_http_basic do |username, password|
          username == Facebase.username && password == Facebase.password
        end
      end
    end


    def set_admin_session
      keys = [:campaign_id, :stream_id]
      keys.each do |key|
        if params[key] == 'u'
          unset_session(key)
        else
          set_session(key, params[key])
        end
      end
    end

    protected

    def set_session(key, val)
      session[key] = val if val.present?
    end

    def unset_session(key)
      session.delete(key)
    end


  end
end
