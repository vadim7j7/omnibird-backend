# frozen_string_literal: true

module MailGateway
  class BaseService < ApplicationService
    prepend Connections::Helpers::EmailSenderCategory

    attr_reader :connection

    # @param[Connection] connection
    # @param[Hash] params
    def initialize(connection:, params: {})
      super(params:)

      @connection = connection
    end

    private

    def call_handler(validate_token: true)
      validate_connection!
      validate_provider!
      validate_and_refresh_token! if validate_token
      yield if block_given?
      validate_params_provider!
      return unless status

      perform!

    rescue Connections::Exceptions::WrongCategoryError,
      Connections::Exceptions::WrongProviderError,
      Connections::Exceptions::InvalidRefreshTokenError,
      Connections::Exceptions::MissingMessageIdError,
      Connections::Exceptions::MissingParamError => err

      @status = false
      @result = { errors: { messages: [ err.message ] } }
      nil
    rescue StandardError => err
      Rails.logger.error(err)
      @status = false
      @result = { errors: { messages: [ 'unknown error' ] } }
      nil
    end

    # @return[Symbol]
    def provider
      @provider ||= connection.provider.to_sym
    end

    def klass
      @klass ||= providers[provider]
    end

    # @return[Hash]
    def provider_params
      @provider_params ||=
        { google: google_params,
          microsoft: microsoft_params,
          smtp: smtp_params }[provider]
    end

    def validate_provider!
      return if klass

      raise Connections::Exceptions::WrongProviderError, "#{provider} is not supported"
    end

    def validate_params_provider!
      raise Connections::Exceptions::WrongProviderError, "#{provider} is not supported" if provider_params.nil?
    end

    def validate_and_refresh_token!
      return unless connection.token_able?
      return if Utils::Token.instance.check_and_refresh_token?(connection:)

      raise Connections::Exceptions::InvalidRefreshTokenError, 'access token is invalid'
    end

    # @return[Hash]
    def providers
      raise NotImplementedError
    end

    # @return[Hash]
    def google_params
      raise NotImplementedError
    end

    # @return[Hash]
    def microsoft_params
      raise NotImplementedError
    end

    # @return[Hash]
    def smtp_params
      raise NotImplementedError
    end

    def perform!
      raise NotImplementedError
    end
  end
end
