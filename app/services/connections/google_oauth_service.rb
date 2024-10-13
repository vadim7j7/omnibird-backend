module Connections
  class GoogleOauthService < Connections::BaseConnection
    def call!
      @result = { oauth_url: }

      nil
    end

    private

    def oauth_url
      url_params = {
        stage:,
        client_id:,
        response_type: 'code',
        redirect_uri: oauth_redirect_uri,
        scope: scopes.join(' ')
      }

      # Save metadata if connection is present!
      save!(metadata: { oauth_params: url_params }, status: :pending) if connection.present?

      "https://accounts.google.com/o/oauth2/v2/auth?#{url_params.to_query}"
    end

    # @return[Array<String>]
    def scopes
      if connection.email_sender?
        %w[https://www.googleapis.com/auth/gmail.compose]
      elsif connection.oauth?
        %w[https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile]
      end
    end

    # @return[String]
    def oauth_redirect_uri
      "#{ENV.fetch('APP_FULL_URI')}/auth/callback/google"
    end

    # @return[String]
    def client_id
      ENV.fetch('SERVICE_GOOGLE_CLIENT_ID')
    end
  end
end
