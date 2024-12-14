# frozen_string_literal: true

module Connections
  module Google
    class AuthBaseService < Connections::BaseConnection
      private

      # @return[String]
      def client_id
        Rails.application.credentials.services.google_client_id
      end

      # @return[String]
      def client_secret
        Rails.application.credentials.services.google_client_secret
      end
    end
  end
end
