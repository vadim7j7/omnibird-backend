module Connections
  module Google
    class SendEmailService < Connections::BaseConnection
      def call!
        validate!(provider: :google)
        validate_connection!
      end

      private

      def validate_connection!
        return if connection.email_sender?

        raise Connections::Exceptions::WrongCategoryError, "#{self.class.name} doesn't support #{connection.category}"
      end

      # @return[String]
      def access_token
        @access_token ||= connection.credentials_parsed[:access_token]
      end

      def token_type
        @token_type ||= connection.credentials_parsed[:token_type]
      end

      # @return[Hash]
      def headers
        { Authorization: "#{token_type} #{access_token}",
          'Content-Type': 'application/json' }
      end
    end
  end
end
