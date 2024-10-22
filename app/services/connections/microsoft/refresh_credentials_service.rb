# frozen_string_literal: true

module Connections
  module Microsoft
    class RefreshCredentialsService < Connections::Microsoft::AuthBaseService
      require 'httparty'

      prepend Connections::Helpers::SaveToken

      def call!
        validate!(provider: :microsoft)
        raise Connections::Exceptions::InvalidRefreshTokenError if refresh_token.blank?

        response = HTTParty.post('https://login.microsoftonline.com/common/oauth2/v2.0/token', body:)
        save_response!(data: response.parsed_response, code: response.code)
        success_connected!(credentials: @credentials) if response.code == 200

        nil
      end

      private

      def body
        { client_id:,
          client_secret:,
          refresh_token:,
          redirect_uri:,
          scope: scopes,
          grant_type: 'refresh_token' }
      end

      # @return[String]
      def refresh_token
        @refresh_token ||=
          connection
          .credentials_parsed[:refresh_token]
      end

      # @return[String]
      def scopes
        @scopes ||= connection.metadata['oauth_params']['scope']
      end

      # @return[String]
      def redirect_uri
        @redirect_uri ||= connection.metadata['oauth_params']['redirect_uri']
      end
    end
  end
end
