# frozen_string_literal: true

module Requests
  module JsonHelpers
    def json
      JSON.parse(response.body, symbolize_names: true)
    end
  end

  module ApiHelpers
    include Auth::TokenHelpers

    # @param[String] path
    # @param[Hash] options
    def api_get(path, options = {})
      headers = signed_in_headers(
        account: options[:account],
        user: options[:user],
        headers: options[:headers] || {}
      )

      get("#{root_path(options)}#{path}", params: options[:params], headers:)
    end

    # @param[String] path
    # @param[Hash] options
    def api_post(path, options = {})
      headers = signed_in_headers(
        account: options[:account],
        user: options[:user],
        headers: options[:headers] || {}
      )

      post("#{root_path(options)}#{path}", params: options[:params], headers:)
    end

    # @param[String] path
    # @param[Hash] options
    def api_put(path, options = {}); end

    # @param[String] path
    # @param[Hash] options
    def api_patch(path, options = {}); end

    # @param[String] path
    # @param[Hash] options
    def api_delete(path, options = {}); end

    # @param[Account] account
    # @param[User] user
    # @param[Hash] headers
    # @return[Hash]
    def signed_in_headers(account: nil, user: nil, headers: nil)
      headers = {} if headers.nil?

      if user
        tokens = issue_access_tokens(user)
        headers['Authorization'] = "#{::Constants::JWT_TOKEN_SCHEME} #{tokens[:access_token]}"
      end

      headers['X-Account'] = account.slug if account

      headers
    end

    private

    # @param[Hash] options
    # @return[String]
    def root_path(options = {})
      version = options.delete(:version).presence || 'v1'
      group   = options.delete(:group).presence || 'internal'

      "/#{version}/#{group}"
    end
  end
end
