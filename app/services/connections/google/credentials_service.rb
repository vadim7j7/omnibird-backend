# frozen_string_literal: true

module Connections
  module Google
    class CredentialsService < Connections::Google::AuthBaseService
      require 'httparty'

      prepend Connections::Helpers::IssueToken
      prepend Connections::Helpers::SaveToken

      TOKEN_URL = 'https://accounts.google.com/o/oauth2/token'.freeze

      def call!
        validate!(provider: :google)

        response = token_data(url: TOKEN_URL)

        save_response!(**response)
        get_and_save_user_info! if credentials.present?

        nil
      end

      private

      def get_and_save_user_info!
        headers = { Authorization: "#{credentials[:token_type]} #{credentials[:access_token]}" }
        response = HTTParty.get('https://www.googleapis.com/oauth2/v1/userinfo', headers:)

        if response.code == 200
          data = response.parsed_response
          connection.uuid = data['id']
          save_source_data!(data:)
        else
          error!(data: { user_info: response.parsed_response.dig('error', 'message') })
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
