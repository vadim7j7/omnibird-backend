# frozen_string_literal: true

module Connections
  module Google
    class CredentialsService < Connections::Google::AuthBaseService
      require 'httparty'

      prepend Connections::Helpers::IssueToken
      prepend Connections::Helpers::SaveToken
      prepend Connections::Google::SaveProfileDataHelper

      TOKEN_URL = 'https://accounts.google.com/o/oauth2/token'.freeze

      def call!
        validate!(provider: :google)

        response = token_data(url: TOKEN_URL)

        save_response!(**response)
        get_and_save_user_info!(headers:) if credentials.present?

        nil
      end

      private

      # @return[Hash]
      def headers
        { Authorization: "#{credentials[:token_type]} #{credentials[:access_token]}" }
      end
    end
  end
end
