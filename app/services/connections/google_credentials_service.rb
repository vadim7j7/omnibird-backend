# frozen_string_literal: true

module Connections
  class GoogleCredentialsService < Connections::BaseConnection
    require 'httparty'

    attr_reader :credentials

    def call!
      validate!(provider: :google)

      response = HTTParty.post(
        'https://accounts.google.com/o/oauth2/token',
        body:,
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
      )

      save_response!(data: response.parsed_response, code: response.code)
      get_and_save_user_info! if credentials.present?
    end

    private

    # @return[Hash]
    def body
      { client_id:,
        client_secret:,
        redirect_uri:,
        grant_type: 'authorization_code',
        code: params[:code] }
    end

    def client_id
      ENV.fetch('SERVICE_GOOGLE_CLIENT_ID')
    end

    def client_secret
      ENV.fetch('SERVICE_GOOGLE_CLIENT_SECRET')
    end

    def redirect_uri
      connection
        .metadata
        .dig('oauth_params', 'redirect_uri')
    end

    # @param[Hash] data
    # @param[Integer] code
    def save_response!(data:, code:)
      if code == 200
        connection.expired_at = data['expires_in'].seconds.from_now
        @credentials = { token_type: data['token_type'],
                         access_token: data['access_token'],
                         refresh_token: data['refresh_token'] }
      else
        error!(data: { token: data['error_description'] })
      end

      nil
    end

    def get_and_save_user_info!
      headers = { Authorization: "#{credentials[:token_type]} #{credentials[:access_token]}" }
      response = HTTParty.get('https://www.googleapis.com/oauth2/v1/userinfo', headers:)

      if response.code == 200
        data = response.parsed_response
        connection.uuid = data['id']
        save_source_data!(data:)
      else
        error!(data: { token: response.parsed_response.dig('error', 'message') })
      end

      nil
    end

    def save_source_data!(data:)
      success_connected!(
        credentials:,
        source_data: {
          avatar: data['picture'],
          email: data['email'],
          first_name: data['given_name'],
          last_name: data['family_name']
        }
      )

      nil
    end
  end
end
