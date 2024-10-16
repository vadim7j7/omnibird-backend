# frozen_string_literal: true

module Connections
  module Microsoft
    class OauthUrlService < Connections::Microsoft::AuthBaseService
      def call!
        validate!(provider: :microsoft)

        @result = { oauth_url: }

        nil
      end

      private

      # @return[String]
      def oauth_url
        url_params = {
          state:,
          client_id:,
          redirect_uri:,
          response_type: 'code',
          scope: scopes.join(' ')
        }

        # Save metadata if connection is present!
        oauth_params!(data: url_params) if connection.present?

        "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?#{url_params.to_query}"
      end

      # @return[Array<String>]
      def scopes
        if connection.email_sender?
          %w[openid profile email offline_access
             https://outlook.office.com/mail.read https://outlook.office.com/mail.send]
        elsif connection.oauth?
          %w[openid profile email]
        end
      end

      # @return[String]
      def redirect_uri
        "#{ENV.fetch('APP_FULL_URI')}/auth/callback/microsoft"
      end
    end
  end
end
