# frozen_string_literal: true

module Connections
  module Google
    class AuthBaseService < Connections::BaseConnection
      private

      # @return[String]
      def client_id
        ENV.fetch('SERVICE_GOOGLE_CLIENT_ID')
      end

      # @return[String]
      def client_secret
        ENV.fetch('SERVICE_GOOGLE_CLIENT_SECRET')
      end
    end
  end
end
