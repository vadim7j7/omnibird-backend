# frozen_string_literal: true

module Connections
  module Microsoft
    class SendEmailService < Connections::BaseConnection
      require 'httparty'

      prepend Connections::Helpers::Authorization

      attr_reader :email_body_payload

      SEND_EMAIL_URL = 'https://graph.microsoft.com/v1.0/me/sendMail'.freeze

      def call!
        validate!(provider: :microsoft)
        validate_connection!

        build_email_body!

        response = HTTParty.post(SEND_EMAIL_URL, body: email_body_payload.to_json, headers:)
        if response.success?
          @status = true
        else
          @result = response.parsed_response.deep_symbolize_keys
          @status = false
        end

        nil
      end

      private

      def validate_connection!
        return if connection.email_sender?

        raise Connections::Exceptions::WrongCategoryError, "#{self.class.name} doesn't support #{connection.category}"
      end

      # @return[Message::MailerService]
      def mailer_service
        params[:mailer_service]
      end

      def build_email_body!
        @email_body_payload = {
          message: {
            subject: mailer_service.message.subject,
            body: {
              contentType: mailer_service.body_type == :html ? 'HTML' : 'Text',
              content: mailer_service.message.html_part.body.raw_source
            },
            toRecipients: recipients,
            ccRecipients: recipients(key: :cc),
            bccRecipients: recipients(key: :bcc),
            replyTo: recipients(key: :reply_to),
            attachments: [],
            internetMessageHeaders: []
          },
          saveToSentItems: true
        }

        add_attachments!
        add_to_thread!

        nil
      end

      # @param[Symbol] key
      # @return[Array<Hash>]
      def recipients(key: :to)
        return [] if %i[to bcc cc reply_to].exclude?(key)

        items = mailer_service.message.send(key)
        return [] if items.blank?

        items.map { |address| { emailAddress: { address: } } }
      end

      def add_custom_headers!
        mailer_service.message.headers.each do |name, value|
          @email_body_payload[:message][:internetMessageHeaders] << { name:, value: }
        end
      end

      def add_attachments!
        return if mailer_service.message.attachments.blank?

        mailer_service.message.attachments.map do |attachment|
          @email_body_payload[:attachments] << {
            '@odata.type': '#microsoft.graph.fileAttachment',
            name: attachment.filename,
            contentType: attachment.content_type,
            contentBytes: Base64.encode64(attachment.body.decoded)
          }
        end

        nil
      end

      def add_to_thread!
        return if mailer_service.message.in_reply_to.blank? || mailer_service.message.references.blank?

        @email_body_payload[:message][:internetMessageHeaders] << {
          name: 'In-Reply-To',
          value: "<#{mailer_service.message.in_reply_to}>"
        }

        @email_body_payload[:message][:internetMessageHeaders] << {
          name: 'References',
          value: mailer_service.message.references&.map { |r| "<#{r}>" }.join(' ')
        }

        nil
      end
    end
  end
end
