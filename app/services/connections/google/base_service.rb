# frozen_string_literal: true

module Connections
  module Google
    class BaseService < Connections::BaseConnection

      private

      # @return[String]
      def client_id
        ENV.fetch('SERVICE_GOOGLE_CLIENT_ID')
      end

      # @return[String]
      def client_secret
        ENV.fetch('SERVICE_GOOGLE_CLIENT_SECRET')
      end

      # @param[Hash] data
      # @param[Integer] code
      def save_response!(data:, code:)
        if code == 200
          connection.expired_at = data['expires_in'].seconds.from_now
          @credentials = { token_type: data['token_type'],
                           access_token: data['access_token'],
                           refresh_token: data['refresh_token'] || connection.credentials_parsed[:refresh_token] }
        else
          error!(data: { token: data['error_description'] })
        end

        nil
      end
    end
  end
end
