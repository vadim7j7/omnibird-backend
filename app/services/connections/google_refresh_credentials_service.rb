# frozen_string_literal: true

module Connections
  class GoogleRefreshCredentialsService < Connections::BaseConnection
    require 'httparty'

    attr_reader :credentials

    def call!
      validate!(provider: :google)
      raise Connections::Exceptions::InvalidRefreshTokenError if refresh_token.blank?

      response = HTTParty.post('https://www.googleapis.com/oauth2/v3/token', body:)
      data = response.parsed_response
      if response.code == 200
        @credentials = { token_type: data['token_type'],
                         access_token: data['access_token'],
                         refresh_token: data['refresh_token'] || refresh_token }
        connection.expired_at = data['expires_in'].seconds.from_now
        success_connected!(credentials: @credentials)
      else
        error!(data: { token: data['error_description'] })
      end

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

    def client_id
      ENV.fetch('SERVICE_GOOGLE_CLIENT_ID')
    end

    def client_secret
      ENV.fetch('SERVICE_GOOGLE_CLIENT_SECRET')
    end
  end
end
