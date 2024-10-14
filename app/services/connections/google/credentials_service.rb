# frozen_string_literal: true

module Connections
  module Google
    class CredentialsService < Connections::Google::AuthBaseService
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

      def redirect_uri
        connection
          .metadata
          .dig('oauth_params', 'redirect_uri')
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
end
