# frozen_string_literal: true

module Connections
  module Helpers
    module IssueToken
      # @param[String] url
      # @return[Hash]
      def token_data(url:)
        response = HTTParty.post(
          url,
          body:,
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        )

        { data: response.parsed_response,
          code: response.code }
      end

      # @return[Hash]
      def body
        { client_id:,
          client_secret:,
          redirect_uri:,
          grant_type: 'authorization_code',
          code: params[:code] }
      end

      # @return[String]
      def redirect_uri
        connection
          .metadata
          .dig('oauth_params', 'redirect_uri')
      end
    end
  end
end
