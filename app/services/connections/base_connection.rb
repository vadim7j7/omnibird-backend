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
    def oauth_redirect_uri
      raise NotImplementedError
    end

    def client_id
      raise NotImplementedError
    end

    def state
      @state ||= SecureRandom.uuid_v7
    end

    # @param[Hash] metadata
    # @param[Symbol] status
    def save!(metadata:, status: :pending)
      connection.metadata = metadata
      connection.status   = status

      # Add state as state token for connection and delete that from metadata.
      if connection.metadata.dig('oauth_params', 'state')
        connection.state_token = connection.metadata['oauth_params']['state']
        connection.metadata['oauth_params'].delete('state')
      end

      connection.save!
    end
  end
end
