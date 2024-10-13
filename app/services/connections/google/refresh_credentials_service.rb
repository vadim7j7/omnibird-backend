# frozen_string_literal: true

module Connections
  module Google
    class RefreshCredentialsService < Connections::Google::BaseService
      require 'httparty'

      attr_reader :credentials

      def call!
        validate!(provider: :google)
        raise Connections::Exceptions::InvalidRefreshTokenError if refresh_token.blank?

        response = HTTParty.post('https://www.googleapis.com/oauth2/v3/token', body:)
        save_response!(data: response.parsed_response, code: response.code)
        success_connected!(credentials: @credentials) if response.code == 200

        nil
      end

      private

      def body
        { client_id:,
          client_secret:,
          refresh_token:,
          grant_type: 'refresh_token' }
      end

      def refresh_token
        @refresh_token ||=
          connection
            .credentials_parsed[:refresh_token]
      end
    end
  end
end
