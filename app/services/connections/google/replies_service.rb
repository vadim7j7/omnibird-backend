# frozen_string_literal: true

module Connections
  module Google
    class RepliesService < Connections::Google::AuthBaseService
      require 'httparty'

      prepend Connections::Helpers::Authorization
      prepend Connections::Helpers::EmailSenderCategory

      MESSAGES_URL = 'https://gmail.googleapis.com/gmail/v1/users/me/threads/{threadId}'.freeze

      def call!
        validate!(provider: :google)
        validate_connection!
        validate_params!

        url = MESSAGES_URL.sub('{threadId}', params[:thread_id])
        response = HTTParty.get(url, headers:)
        data = response.parsed_response.deep_symbolize_keys
        if response.success?
          find_replies!(items: data[:messages])
        else
          @result = data
          @status = false
        end

        nil
      end

      private

      # @param[Array<Hash>]
      def find_replies!(items:)
        @result[:source_data] =
          items
          .select { |item| item[:payload][:headers].any? { |r| r[:name] == 'In-Reply-To' } }

        nil
      end

      def validate_params!
        raise Connections::Exceptions::MissingMessageIdError, 'thread_id is missing' if params[:thread_id].blank?
      end
    end
  end
end
