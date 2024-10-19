# frozen_string_literal: true

module Connections
  module Microsoft
    module SaveProfileDataHelper
      PROFILE_URL = 'https://graph.microsoft.com/v1.0/me'.freeze
      AVATAR_URL = 'https://graph.microsoft.com/v1.0/me/photo/$value'.freeze

      def get_and_save_user_info!(headers:)
        response = HTTParty.get(PROFILE_URL, headers:)

        if response.code == 200
          data = response.parsed_response
          connection.uuid = data['id']
          save_source_data!(data:)
          get_and_save_user_avatar!(headers:)
        else
          error!(data: { user_info: response.parsed_response.dig('error', 'message') })
        end

        nil
      end

      def get_and_save_user_avatar!(headers:)
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
