# frozen_string_literal: true

module Message
  class MailerService
    require 'mime/types'

    attr_reader :params, :message, :body_type

    def initialize(params: {}, body_type: :html)
      @params    = params
      @body_type = body_type
      @message   = Mail.new
    end

    def call
      message.from        = params[:from]
      message.to          = params[:to]
      message.reply_to    = params[:reply_to] if params[:reply_to].present?
      message.bcc         = params[:bcc] if params[:bcc].present?
      message.cc          = params[:cc] if params[:cc].present?
      message.in_reply_to = params[:in_reply_to] if params[:in_reply_to].present?
      message.references  = references
      message.subject     = subject
      message.message_id  = message_id

      add_body!
      add_attachments!
    end

    def as_string
      Base64.urlsafe_encode64(message.to_s)
    end

    private

    # @return[String]
    def subject
      if params[:in_reply_to].present?
        "Re: #{params[:subject] || 'No Subject'}"
      else
        params[:subject] || 'No Subject'
      end
    end

    # @return[String]
    def references
      return if params[:in_reply_to].blank?

      if params[:references].present?
        (params[:references] + [ params[:in_reply_to] ]).uniq.join(' ')
      else
        params[:in_reply_to]
      end
    end

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
        add_attachment!(file_path: item.path) if item.is_a?(File) || item.is_a?(Tempfile)
      end

      nil
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

      nil
    end

    # @return[String]
    def message_id
      return @message_id if @message_id.present?

      email = message.from&.first
      return if email.blank?

      domain = email.split('@').last

      @message_id = "#{SecureRandom.hex(16)}@mail.#{domain}"
    end
  end
end
