# frozen_string_literal: true

module Connections
  module Microsoft
    class EmailDetailsService < Connections::Microsoft::AuthBaseService
      require 'httparty'

      prepend Connections::Helpers::Authorization
      prepend Connections::Helpers::EmailSenderCategory

      LIMIT = 20
      MESSAGES_URL = 'https://graph.microsoft.com/v1.0/me/mailFolders/sentItems/messages'.freeze

      def call!
        validate!(provider: :microsoft)
        validate_connection!
        validate_params!

        response = HTTParty.get(MESSAGES_URL, headers:, query:)
        data = response.parsed_response.deep_symbolize_keys
        if response.success?
          find_email!(items: data[:value])
        else
          @status = false
          @result = data
        end
      end

      private

      # @param[Array<Hash>]
      def find_email!(items:)
        filtered_messages = items.select do |message|
          message[:subject] == params[:subject] &&
            message[:toRecipients].any? { |recipient| recipient[:emailAddress][:address] == params[:to] }
        end

        if filtered_messages.first
          @result[:source_data] = filtered_messages.first
        else
          @status = false
        end

        nil
      end

      def query
        { '$top': LIMIT,
          '$orderby': 'sentDateTime desc' }
      end

      def validate_params!
        raise Connections::Exceptions::MissingMessageIdError, 'identifier subject is missing' if params[:subject].blank?
        raise Connections::Exceptions::MissingMessageIdError, 'identifier to is missing' if params[:to].blank?
      end
    end
  end
end
