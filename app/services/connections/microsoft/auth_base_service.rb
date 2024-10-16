# frozen_string_literal: true

module Connections
  module Microsoft
    class AuthBaseService < Connections::BaseConnection
      private

      # @return[String]
      def client_id
        ENV.fetch('SERVICE_MICROSOFT_CLIENT_ID')
      end

      # @return[String]
      def client_secret
        ENV.fetch('SERVICE_MICROSOFT_CLIENT_SECRET')
      end

      # @param[Hash] data
      # @param[Integer] code
      def save_response!(data:, code:)
        if code == 200
        else
          error!(data: { token: data['error_description'] })
        end

        nil
      end
    end
  end
end
