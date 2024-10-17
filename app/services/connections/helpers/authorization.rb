# frozen_string_literal: true

module Connections
  module Helpers
    module Authorization
      # @return[String]
      def access_token
        @access_token ||= connection.credentials_parsed[:access_token]
      end

      # @return[String]
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
