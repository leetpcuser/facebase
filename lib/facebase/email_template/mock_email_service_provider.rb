module Facebase
  module EmailTemplate
    class MockEmailServiceProvider

      def name
        "test email service provider"
      end

      def address
        "smtp.sendgrid.com"
      end

      def port
        574
      end

      def domain
        "test.com"
      end

      def user_name
        "username"
      end

      def password
        "password"
      end

      def authentication
        "plain"
      end

      def enable_starttls_auto
        true
      end

      def enable_sendgrid_tracking
        true
      end

      def enable_auto_google_analytics
        true
      end

    end
  end
end
