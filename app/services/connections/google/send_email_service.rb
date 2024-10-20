# frozen_string_literal: true

module Connections
  module Google
    class SendEmailService < Connections::BaseConnection
      require 'httparty'

      prepend Connections::Helpers::Authorization
      prepend Connections::Helpers::EmailSenderCategory

      def call!
        validate!(provider: :google)
        validate_connection!

        response = HTTParty.post('https://gmail.googleapis.com/gmail/v1/users/me/messages/send', body:, headers:)
        if response.success?
          @result[:api_message] = response.parsed_response.deep_symbolize_keys
        else
          @result = response.parsed_response.deep_symbolize_keys
          @status = false
        end

        nil
      end

      private

      def body
        { raw: params[:encoded_message] }.to_json
      end
    end
  end
end
