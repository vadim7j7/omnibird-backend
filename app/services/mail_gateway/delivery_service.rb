# frozen_string_literal: true

module MailGateway
  class DeliveryService < ApplicationService
    prepend Connections::Helpers::EmailSenderCategory

    PROVIDERS = {
      google: Connections::Google::SendEmailService,
      microsoft: Connections::Microsoft::SendEmailService
    }

    attr_reader :connection, :mailer_service

    # @param[Connection] connection
    # @param[Hash] params
    def initialize(connection:, params: {})
      super(params:)

      @connection = connection
    end

    private

    def call!
      validate_connection!
      validate_provider!
      validate_and_refresh_token!
      build_mailer_service!
      return unless status

      perform!

    rescue Connections::Exceptions::WrongCategoryError,
           Connections::Exceptions::WrongProviderError,
           Connections::Exceptions::InvalidRefreshTokenError => err

      @status = false
      @result = { errors: { messages: [ err.message ] } }
    rescue StandardError => err
      Rails.logger.error(err)
      @status = false
      @result = { errors: { messages: [ 'unknown error' ] } }
    ensure
      nil
    end

    def klass
      @klass ||= PROVIDERS[connection.provider.to_sym]
    end

    def validate_provider!
      return if klass

      raise Connections::Exceptions::WrongProviderError, "#{connection.provider} is not supported"
    end

    # @return[Hash]
    def provider_params
      @provider_params ||=
        { google: google_params,
          microsoft: microsoft_params }[connection.provider.to_sym]
    end

    def validate_and_refresh_token!
      return if Utils::Token.instance.check_and_refresh_token?(connection:)

      raise Connections::Exceptions::InvalidRefreshTokenError, 'access token is invalid'
    end

    def google_params
      { encoded_message: mailer_service.as_string,
        thread_id: params[:thread_id] }
    end

    def microsoft_params
      { mailer_service: }
    end

    def build_mailer_service!
      @mailer_service = Message::MailerService.new(params: params[:mail_message_params])
      @mailer_service.call
      return if @mailer_service.status

      @status = false
      @result = @mailer_service.result

      nil
    end

    def perform!
      if provider_params.nil?
        raise Connections::Exceptions::WrongProviderError, "#{connection.provider} is not supported"
      end

      service = klass.new(connection:, params: provider_params)
      service.call!

      @status = service.status
      @result = service.result

      nil
    end
  end
end
