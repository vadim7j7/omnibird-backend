# frozen_string_literal: true

module Connections
  module Microsoft
    class CredentialsService < Connections::Microsoft::AuthBaseService
      require 'httparty'

      prepend Connections::Helpers::IssueToken
      prepend Connections::Helpers::SaveToken

      TOKEN_URL = 'https://login.microsoftonline.com/common/oauth2/v2.0/token'.freeze
      PROFILE_URL = 'https://graph.microsoft.com/v1.0/me'.freeze
      AVATAR_URL = 'https://graph.microsoft.com/v1.0/me/photo/$value'.freeze

      def call!
        validate!(provider: :microsoft)

        response = token_data(url: TOKEN_URL)
        save_response!(**response)
        get_and_save_user_info! if credentials.present?

        nil
      end

      private

      def get_and_save_user_info!
        headers = { Authorization: "#{credentials[:token_type]} #{credentials[:access_token]}",
                    'Content-Type': 'application/json' }
        response = HTTParty.get(PROFILE_URL, headers:)

        if response.code == 200
          data = response.parsed_response
          connection.uuid = data['id']
          save_source_data!(data:)
          get_and_save_user_avatar!
        else
          error!(data: { user_info: response.parsed_response.dig('error', 'message') })
        end

        nil
      end

      def get_and_save_user_avatar!
        headers = { Authorization: "#{credentials[:token_type]} #{credentials[:access_token]}",
                    'Content-Type': 'application/json' }
        response = HTTParty.get(AVATAR_URL, headers:)

        if response.success?
          connection.provider_source_data['avatar_base64'] = Base64.encode64(response.body)
          connection.save
        elsif response.parsed_response.dig('error', 'code') == 'ImageNotFound'
          # Exit if the image was not found.
        else
          error!(data: { user_info: response.parsed_response.dig('error', 'message') })
        end
      end

      def save_source_data!(data:)
        success_connected!(
          credentials:,
          source_data: {
            avatar: nil,
            email: data['mail'],
            first_name: data['givenName'],
            last_name: data['surname']
          }
        )

        nil
      end
    end
  end
end
