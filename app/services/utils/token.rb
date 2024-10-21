# frozen_string_literal: true

module Utils
  class Token
    include Singleton

    PROVIDERS = {
      refresh_token: {
        google: Connections::Google::RefreshCredentialsService,
        microsoft: Connections::Microsoft::RefreshCredentialsService
      }
    }.freeze

    # @param[Connection] connection
    # @param[Boolean] force_refresh
    # @return[Boolean]
    def check_and_refresh_token?(connection:, force_refresh: false)
      return true unless connection.expired? || force_refresh

      klass = PROVIDERS[:refresh_token][connection.provider.to_sym]
      return false if klass.nil?

      service = klass.new(connection:)
      service.call!
      service.status
    rescue Connections::Exceptions::InvalidRefreshTokenError
      false
    end
  end
end
