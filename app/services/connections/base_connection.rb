# frozen_string_literal: true

module Connections
  class BaseConnection < ApplicationService
    attr_reader :connection

    # @param[Connection] connection
    # @param[Hash] params
    def initialize(connection:, params: {})
      super(params:)

      @connection = connection
    end

    # @return[Array<String>]
    def scopes
      raise NotImplementedError
    end

    # @return[String]
    def redirect_uri
      raise NotImplementedError
    end

    def client_id
      raise NotImplementedError
    end

    def client_secret
      raise NotImplementedError
    end

    def state
      @state ||= SecureRandom.uuid_v7
    end

    # @param[Hash] data
    def oauth_params!(data:)
      connection.metadata['oauth_params'] = data.deep_stringify_keys
      connection.status                   = :pending

      if connection.metadata.dig('oauth_params', 'state').present?
        connection.state_token = connection.metadata['oauth_params']['state']
        connection.metadata['oauth_params'].delete('state')
      end

      connection.save!

      nil
    end

    # @param[Hash] credentials
    # @param[Hash] source_data
    def success_connected!(credentials:, source_data: {})
      connection.credentials          = credentials.to_json if credentials.present? && !connection.oauth?
      connection.provider_source_data = source_data if source_data.present?
      connection.status               = :connected
      connection.state_token          = nil
      connection.provider_errors      = nil

      connection.save!

      nil
    end

    # @param[Hash] data
    def error!(data:)
      connection.provider_errors = data
      connection.status          = :failed

      connection.save!

      @status = false

      nil
    end

    # @param[Symbol] provider
    def validate!(provider:)
      return if connection.provider.to_sym == provider

      message = "#{self.class.name} doesn't support '#{connection.provider || 'unknown'}' provider"

      raise Connections::Exceptions::WrongProviderError, message
    end

    def validate_access_token!
      return unless connection.expired?

      raise Connections::Exceptions::AccessTokenExpiredError, 'access token is expired'
    end
  end
end
