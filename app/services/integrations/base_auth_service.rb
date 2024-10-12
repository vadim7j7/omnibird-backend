module Integrations
  class BaseAuthService < ApplicationService
    attr_reader :token, :refresh_token, :credentials

    def initialize(params = {})
      super(params:)

      @auth_code     = params[:auth_code]
      @token         = params[:token]
      @refresh_token = params[:refresh_token]
      @credentials   = params[:credentials]
    end

    # @return[String]
    def oauth_url
      raise NotImplementedError
    end

    def refresh_token!
      raise NotImplementedError
    end

    def exchange_token!
      raise NotImplementedError
    end

    # @return[Boolean]
    def token?
      raise NotImplementedError
    end

    # @return[String]
    def oauth_redirect_uri
      raise NotImplementedError
    end
  end
end
