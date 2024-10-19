# frozen_string_literal: true

module Connections
  module Microsoft
    class CredentialsService < Connections::Microsoft::AuthBaseService
      require 'httparty'

      prepend Connections::Helpers::IssueToken
      prepend Connections::Helpers::SaveToken
      prepend Connections::Microsoft::SaveProfileDataHelper

      TOKEN_URL = 'https://login.microsoftonline.com/common/oauth2/v2.0/token'.freeze

      def call!
        validate!(provider: :microsoft)

        response = token_data(url: TOKEN_URL)
        save_response!(**response)
        get_and_save_user_info!(headers:) if credentials.present?

        nil
      end

      private

      # @return[Hash]
      def headers
        { Authorization: "#{credentials[:token_type]} #{credentials[:access_token]}",
          'Content-Type': 'application/json' }
      end
    end
  end
end
