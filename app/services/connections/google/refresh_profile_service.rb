# frozen_string_literal: true

module Connections
  module Google
    class RefreshProfileService < Connections::Google::AuthBaseService
      require 'httparty'

      prepend Connections::Helpers::Authorization
      prepend Connections::Google::SaveProfileDataHelper

      def call!
        validate!(provider: :google)
        validate_access_token!

        get_and_save_user_info!(headers:)

        nil
      end

      def credentials; end
    end
  end
end
