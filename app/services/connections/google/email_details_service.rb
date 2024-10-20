# frozen_string_literal: true

module Connections
  module Google
    class EmailDetailsService < Connections::BaseConnection
      require 'httparty'

      prepend Connections::Helpers::Authorization
      prepend Connections::Helpers::EmailSenderCategory

      MESSAGE_URL = 'https://gmail.googleapis.com/gmail/v1/users/me/messages/{messageId}'.freeze

      def call!
        validate!(provider: :google)
        validate_connection!

        raise Connections::Exceptions::MissingMessageIdError if params[:message_id].blank?

        url = MESSAGE_URL.sub('{messageId}', params[:message_id])
        response = HTTParty.get(url, headers:)

        @result = response.parsed_response.deep_symbolize_keys
        @status = response.success?
      end
    end
  end
end
