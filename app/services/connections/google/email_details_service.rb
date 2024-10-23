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

        raise Connections::Exceptions::MissingMessageIdError, 'message_id is missing' if params[:message_id].blank?

        url = MESSAGE_URL.sub('{messageId}', params[:message_id])
        response = HTTParty.get(url, headers:)

        @status = response.success?
        @result[:source_data] = response.parsed_response.deep_symbolize_keys
      end
    end
  end
end
