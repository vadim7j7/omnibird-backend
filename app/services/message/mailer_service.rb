# frozen_string_literal: true

class Message
  class MailerService
    require 'mime/types'

    attr_reader :params, :message, :body_type

    def initialize(params: {}, body_type: :html)
      @message   = Mail.new
      @body_type = body_type
    end

    def call
      message.from    = params[:from]
      message.to      = params[:to]
      message.subject = params[:subject]

      add_body!
      add_attachments!
    end

    def as_string
      Base64.urlsafe_encode64(message.to_s)
    end

    private

    def add_body!
      return if params[:body].blank?

      mail_part      = Mail::Part.new
      mail_part.body = params[:body]

      if body_type == :html
        message.html_part = mail_part
      else
        message.text_part = mail_part
      end

      nil
    end

    def add_attachments!
      return unless params[:attachments].is_a?(Array)

      params[:attachments].map do |item|
        add_attachment!(file_path: item) if item.is_a?(String)
      end
    end

    # @param[String] file_path
    def add_attachment!(file_path:)
      return unless File.exist?(file_path)

      filename     = File.basename(file_path)
      content_type = MIME::Types.type_for(file_path).first.content_type

      attachment                           = Mail::Part.new
      attachment.content_type              = content_type
      attachment.content_disposition       = "attachment; filename=#{filename}"
      attachment.content_transfer_encoding = 'base64'
      attachment.body                      = Base64.encode64(File.read(file_path))

      message.add_part(attachment)
    end
  end
end
