# frozen_string_literal: true

module Connections
  module Microsoft
    class AuthBaseService < Connections::BaseConnection
      private

      # @return[String]
      def client_id
        Rails.application.credentials.services.microsoft_client_id
      end

      # @return[String]
      def client_secret
        Rails.application.credentials.services.microsoft_client_secret
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
