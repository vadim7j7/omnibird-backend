# frozen_string_literal: true

module Connections
  class GoogleOauthUrlService < Connections::BaseConnection
    def call!
      validate!(provider: :google)

      @result = { oauth_url: }

      nil
    end

    private

    def oauth_url
      url_params = {
        state:,
        client_id:,
        redirect_uri:,
        response_type: 'code',
        scope: scopes.join(' '),
        **extra_url_params
      }

      # Save metadata if connection is present!
      oauth_params!(data: url_params) if connection.present?

      "https://accounts.google.com/o/oauth2/v2/auth?#{url_params.to_query}"
    end

    # @return[Hash]
    def extra_url_params
      if connection.email_sender?
        { access_type: 'offline', prompt: 'consent' }
      else
        {}
      end
    end

    # @return[Array<String>]
    def scopes
      if connection.email_sender?
        %w[https://www.googleapis.com/auth/userinfo.email
           https://www.googleapis.com/auth/userinfo.profile
           https://www.googleapis.com/auth/gmail.compose]
      elsif connection.oauth?
        %w[https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile]
      end
    end

    # @return[String]
    def client_id
      ENV.fetch('SERVICE_GOOGLE_CLIENT_ID')
    end

    # @return[String]
    def redirect_uri
      "#{ENV.fetch('APP_FULL_URI')}/auth/callback/google"
    end
  end
end
