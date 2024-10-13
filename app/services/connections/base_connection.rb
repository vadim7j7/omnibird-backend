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

    def stage
      @stage ||= SecureRandom.uuid_v7
    end

    # @param[Hash] metadata
    # @param[Symbol] status
    def save!(metadata:, status: :pending)
      # Add stage as stage token for connection and delete that from metadata.
      if metadata.dig(:oauth_params, :stage)
        connection.stage_token = metadata[:oauth_params][:stage]
        metadata[:oauth_params].delete(:stage)
      end

      connection.metadata = metadata
      connection.status   = status

      connection.save!
    end
  end
end
