# frozen_string_literal: true

module Connections
  module Smtp
    class CredentialsService < Connections::BaseConnection
      require 'net/smtp'

      prepend Connections::Helpers::EmailSenderCategory

      REQUIRED_PARAMS = %i[address port username password].freeze

      def call!
        validate!(provider: :smtp)
        validate_connection!
        validate_params!
        test_connection!
        save_credentials!
      end

      def validate_params!
        missing_params = REQUIRED_PARAMS.select { |param| params[param].blank? }
        return if missing_params.empty?

        error!(data: missing_params.index_with { |param| "#{param} is required" })
        raise Connections::Exceptions::MissingParamError, "Missing required parameters: #{missing_params.join(', ')}"
      end

      # @return[Symbol]
      def authentication
        @authentication ||= params.fetch(:authentication, 'plain').to_sym
      end

      # @return[Boolean]
      def enable_starttls_auto
        @enable_starttls_auto ||= params.fetch(:enable_starttls_auto, true)
      end

      def test_connection!
        smtp = Net::SMTP.new(params[:address], params[:port])
        smtp.enable_starttls_auto if enable_starttls_auto

        begin
          smtp.start(params[:domain], params[:username], params[:password], authentication)
          smtp.finish
        rescue Net::SMTPAuthenticationError => e
          error!(data: { authentication: 'Invalid credentials' })
          raise e
        rescue StandardError => e
          error!(data: { connection: e.message })
          raise e
        end
      end

      def save_credentials!
        credentials = {
          address:  params[:address],
          port:     params[:port],
          domain:   params[:domain],
          username: params[:username],
          password: params[:password],
          authentication:,
          enable_starttls_auto:
        }

        connection.uuid        = SecureRandom.uuid if connection.uuid.blank?
        connection.credentials = credentials.to_json
        connection.status      = :connected
        connection.save!

        @result = { message: 'SMTP credentials saved successfully' }
      end
    end
  end
end
