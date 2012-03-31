module Facebase
  module MixpanelClient

    def self.track(event, properties={})
      properties = properties.with_indifferent_access
      raise "Token is required" if !properties.has_key?("token")

      # Schedule execution on the reactor
      self.ensure_reactor_alive
      EM.schedule do
        begin
          # construct the request
          params = {"event" => event, "properties" => properties}
          data = ActiveSupport::Base64.encode64(JSON.generate(params))

          # Send the request
          http = EventMachine::HttpRequest.new('http://api.mixpanel.com/track/').post :body => {:data => data}

          # Log the errors
          http.errback do
            error = "Failed to log event:#{event}, properties:#{properties.inspect}"
            if @logger
              @logger.error(error)
            else
              STDERR.puts(error)
            end
          end

          http.callback {
            p "Mixpanel event #{event} fired"
          }
        rescue => e
          pp e.message
          pp e.backtrace
        end

      end
    end


    protected

    def self.ensure_reactor_alive
      @semaphore ||= Mutex.new
      @semaphore.synchronize do
        return if @reactor_thread.present? && @reactor_thread.alive? && EM.reactor_running?

        # Construct the reactor thread and wait for EM to boot
        @reactor_thread = Thread.new { EM.run }
        @reactor_thread.join(1)

        # Don't nuke the web server if the reactor goes down
        @reactor_thread.abort_on_exception= false
      end
    end


  end
end
