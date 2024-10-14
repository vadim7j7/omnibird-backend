# frozen_string_literal: true

module Connections
  module Google
    class SendEmailService < Connections::BaseConnection
      require 'httparty'

      def call!
        validate!(provider: :google)
        validate_connection!

        response = HTTParty.post('https://gmail.googleapis.com/gmail/v1/users/me/messages/send', body:, headers:)

        if response.success?
          @result = response.parsed_response
        else
          @result[:error] = response.parsed_response['error']
          @status = false
        end

        nil
      end

      private

      def validate_connection!
        return if connection.email_sender?

        raise Connections::Exceptions::WrongCategoryError, "#{self.class.name} doesn't support #{connection.category}"
      end

      # @return[String]
      def access_token
        @access_token ||= connection.credentials_parsed[:access_token]
      end

      def token_type
        @token_type ||= connection.credentials_parsed[:token_type]
      end

      # @return[Hash]
      def headers
        { Authorization: "#{token_type} #{access_token}",
          'Content-Type': 'application/json' }
      end

      def body
        { raw: params[:encoded_message] }.to_json
      end
    end
  end
end
