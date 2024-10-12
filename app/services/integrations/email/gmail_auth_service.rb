module Integrations
  module Email
    class GmailAuthService < Integrations::BaseAuthService
      def oauth_url
        url_params = {
          response_type: 'code',
          client_id: 'client_id',
          redirect_uri: oauth_redirect_uri,
          scope: scopes.join(' ')
        }

        "https://accounts.google.com/o/oauth2/v2/auth?#{url_params.to_query}"
      end

      def exchange_token!
      end

      # @return[String]
      def oauth_redirect_uri
        ''
      end

      # @return[String]
      def client_id
        ''
      end

      # @return[Array<String>]
      def scopes
        %w[https://www.googleapis.com/auth/gmail.compose]
      end
    end
  end
end
