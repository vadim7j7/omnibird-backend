# frozen_string_literal: true

module Connections
  module Microsoft
    class SendEmailService < Connections::BaseConnection
      require 'httparty'

      prepend Connections::Helpers::Authorization
      prepend Connections::Helpers::EmailSenderCategory

      attr_reader :email_body_payload

      SEND_EMAIL_URL  = 'https://graph.microsoft.com/v1.0/me/sendMail'.freeze
      REPLY_EMAIL_URL = 'https://graph.microsoft.com/v1.0/me/messages/{messageId}/reply'.freeze

      def call!
        validate!(provider: :microsoft)
        validate_connection!

        build_email_body!

        response = HTTParty.post(send_url, body: email_body_payload.to_json, headers:)
        if response.success?
          @result[:api_request] = { to: mailer_service.message.to, subject: mailer_service.message.subject }
        else
          @result = response.parsed_response.deep_symbolize_keys
          @status = false
        end

        nil
      end

      private

      def send_url
        if mailer_service.message.in_reply_to.present?
          REPLY_EMAIL_URL.sub('{messageId}', mailer_service.message.in_reply_to)
        else
          SEND_EMAIL_URL
        end
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
            }
          },
          saveToSentItems: true
        }

        add_recipients!
        add_attachments!

        nil
      end

      def add_recipients!
        recipients(to_key: :toRecipients, key: :to)
        recipients(to_key: :ccRecipients, key: :cc)
        recipients(to_key: :bccRecipients, key: :bcc)
        recipients(to_key: :replyTo, key: :reply_to)
      end

      # @param[Symbol] to_key
      # @param[Symbol] key
      # @return[Array<Hash>]
      def recipients(to_key:, key: :to)
        return [] if %i[to bcc cc reply_to].exclude?(key)

        items = mailer_service.message.send(key)
        return [] if items.blank?

        @email_body_payload[:message][to_key] = items.map { |address| { emailAddress: { address: } } }
      end

      def add_custom_headers!
        mailer_service.message.headers.each do |name, value|
          @email_body_payload[:message][:internetMessageHeaders] << { name:, value: }
        end
      end

      def add_attachments!
        return if mailer_service.message.attachments.blank?

        @email_body_payload[:message][:attachments] =
          mailer_service.message.attachments.map do |attachment|
            { '@odata.type': '#microsoft.graph.fileAttachment',
              name: attachment.filename,
              contentType: attachment.content_type,
              contentBytes: Base64.encode64(attachment.body.decoded) }
          end

        nil
      end
    end
  end
end
