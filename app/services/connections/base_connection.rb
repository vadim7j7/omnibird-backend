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
      connection.metadata['oauth_params'] = data
      connection.status                   = :pending

      if connection.metadata.dig('oauth_params', 'state').present?
        connection.state_token = connection.metadata['oauth_params']['state']
        connection.metadata['oauth_params'].delete('state')
      end

      connection.save!

      nil
    end

    # @param[Hash] credentials
    # @param[Hash] service_source_data
    def success_connected!(credentials:, service_source_data:)
      connection.credentials         = credentials unless credentials.oauth?
      connection.service_source_data = service_source_data
      connection.status              = :connected
      connection.state_token         = nil
      connection.service_errors      = nil

      connection.save!

      nil
    end

    # @param[Hash] data
    def error!(data:)
      connection.service_source_data = data
      connection.status              = :failed

      connection.save!

      @status = false

      nil
    end
  end
end
