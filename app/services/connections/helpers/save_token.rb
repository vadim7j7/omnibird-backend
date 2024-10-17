# frozen_string_literal: true

module Connections
  module Helpers
    module SaveToken
      attr_reader :credentials

      # @param[Hash] data
      # @param[Integer] code
      def save_response!(data:, code:)
        if code == 200
          connection.expired_at = data['expires_in'].seconds.from_now
          @credentials = { token_type: data['token_type'],
                           access_token: data['access_token'],
                           refresh_token: data['refresh_token'] || connection.credentials_parsed[:refresh_token] }
        else
          error!(data: { token: data['error_description'] })
        end

        nil
      end
    end
  end
end
