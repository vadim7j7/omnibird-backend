# frozen_string_literal: true

module MailGateway
  class DeliveryService
    include Singleton

    PROVIDERS = {
      google: Connections::Google::SendEmailService,
      microsoft: Connections::Microsoft::SendEmailService
    }

    # @param[Connection] connection
    def perform!(connection:, params: {})
      klass = PROVIDERS[connection.provider.to_sym]
      raise Connections::Exceptions::WrongProviderError, "#{connection.provider} is not supported" if klass.nil?
      return unless Utils::Token.instance.check_and_refresh_token?(connection:)

      nil
    end
  end
end
