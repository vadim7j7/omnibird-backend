# frozen_string_literal: true

module Connections
  module Microsoft
    class RefreshProfileService < Connections::Microsoft::AuthBaseService
      require 'httparty'

      prepend Connections::Helpers::Authorization
      prepend Connections::Microsoft::SaveProfileDataHelper

      def call!
        validate!(provider: :microsoft)
        validate_access_token!

        get_and_save_user_info!(headers:)

        nil
      end

      def credentials; end
    end
  end
end
