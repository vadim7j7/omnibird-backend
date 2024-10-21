# frozen_string_literal: true

module Connections
  module Microsoft
    class RepliesService < Connections::Microsoft::AuthBaseService
      require 'httparty'

      prepend Connections::Helpers::Authorization
      prepend Connections::Helpers::EmailSenderCategory

      MESSAGES_URL = 'https://graph.microsoft.com/v1.0/me/messages'.freeze

      def call!
        validate!(provider: :microsoft)
        validate_connection!
        validate_params!

        response = HTTParty.get(MESSAGES_URL, headers:, query:)
        data = response.parsed_response.deep_symbolize_keys
        if response.success?
          find_replies!(items: data[:value])
        else
          @result = data
          @status = false
        end
      end

      private

      # @param[Array<Hash>] items
      def find_replies!(items:)
        @result[:source_data] =
          items
          .sort_by { |message| message[:sentDateTime] }
          .reverse
          .select { |item| item[:conversationId] == params[:thread_id] && item[:subject].start_with?('Re:') }

        nil
      end

      # @return[Hash]
      def query
        { '$filter': "conversationId eq '#{params[:thread_id]}'" }
      end

      def validate_params!
        raise Connections::Exceptions::MissingMessageIdError, 'thread_id is missing' if params[:thread_id].blank?
      end
    end
  end
end
