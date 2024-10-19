# frozen_string_literal: true

module Connections
  module Google
    module SaveProfileDataHelper
      PROFILE_URL = 'https://www.googleapis.com/oauth2/v1/userinfo'.freeze

      def get_and_save_user_info!(headers:)
        response = HTTParty.get(PROFILE_URL, headers:)

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
