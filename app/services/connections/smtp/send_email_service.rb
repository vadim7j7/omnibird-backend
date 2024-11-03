# frozen_string_literal: true

module Connections
  module Smtp
    class SendEmailService < Connections::BaseConnection
      prepend Connections::Helpers::EmailSenderCategory

      def call!
        validate!(provider: :smtp)
        validate_connection!
        validate_params!
        send_email!

        nil
      end

      private

      def validate_params!
        return if mailer_service.present?

        raise Connections::Exceptions::MissingParamError, 'missing mailer_service'
      end

      def send_email!
        smtp.start(smtp_settings[:domain],
                   smtp_settings[:username],
                   smtp_settings[:password],
                   smtp_settings[:authentication]) do |smtp_connection|
          smtp_connection.send_message(mailer_service.message.to_s,
                                       mailer_service.message.from.first,
                                       mailer_service.message.to)
        end
        @result = { message: 'Email sent successfully' }
      rescue Net::SMTPAuthenticationError => e
        @status = false
        @result = { error: 'SMTP authentication failed', details: e.message }
      rescue StandardError => e
        @status = false
        @result = { error: 'Failed to send email', details: e.message }
      end

      # @return[Net::SMTP]
      def smtp
        return @smtp if @smtp

        @smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
        @smtp.enable_starttls_auto if smtp_settings[:enable_starttls_auto]

        @smtp
      end

      # @return[Message::MailerService]
      def mailer_service
        params[:mailer_service]
      end

      # @return[Hash]
      def smtp_settings
        @smtp_settings ||= connection.credentials_parsed
      end
    end
  end
end
