# frozen_string_literal: true

module Handlers
  class SendMailService < ApplicationService
    attr_reader :connection

    # @param[Connection] connection
    # @param[Hash] params
    # @param[Hash] options
    def initialize(connection:, params: {}, options: {})
      super(params:)

      @connection = connection
      @options    = options
    end

    def call!
      message_sent_session.pending!

      inject_tracking!
      process_stage_send!
      process_stage_retrieve! if status
      save_result!

      nil
    end

    # @return[MessageSentSession]
    def message_sent_session
      @message_sent_session ||= MessageSentSession.new(connection:)
    end

    private

    def process_stage_send!
      service = MailGateway::DeliveryService.new(
        connection:,
        params: { mail_message_params: params[:mail_message_params], thread_id: params[:thread_id] }
      )
      service.call
      @status = service.status

      message_sent_session.raw_message          = service.mailer_service.as_string
      message_sent_session.data_source_response = service.result
      message_sent_session.sent!

      nil
    end

    # Load message details by message_id for Google or (email and subject) for Microsoft
    # and save result to database.
    def process_stage_retrieve!
      service = MailGateway::RetrieveService.new(connection:, params: {
        message_id: message_sent_session.data_source_response&.dig('api_message', 'id'),
        subject:    message_sent_session.data_source_response&.dig('api_request', 'subject'),
        email:      message_sent_session.data_source_response&.dig('api_request', 'to', 0),
        thread:     message_sent_session.data_source_response&.dig('thread')&.deep_symbolize_keys
      })
      service.call
      @status = service.status

      message_sent_session.data_source_message_details = service.result
      message_sent_session.retrieve!

      nil
    end

    def save_result!
      return message_sent_session.failed! unless status

      add_message_id!
      add_thread_id!
      add_mail_id!

      message_sent_session.completed!
    end

    # Find message id from source respond data
    def add_message_id!
      message_sent_session.message_id =
        message_sent_session
        .data_source_message_details
        .dig('source_data', 'id')
    end

    # Find thread id from source respond data
    def add_thread_id!
      message_sent_session.thread_id =
        if connection.google?
          message_sent_session
            .data_source_message_details
            .dig('source_data', 'threadId')
        elsif connection.microsoft?
          message_sent_session
            .data_source_message_details
            .dig('source_data', 'conversationId')
        elsif connection.smtp?
          message_sent_session
            .data_source_message_details
            .dig('source_data', 'thread_id')
        end
    end

    # Find message id of the email from source respond data
    def add_mail_id!
      message_sent_session.mail_id =
        if connection.google?
          message_sent_session
            .data_source_message_details
            .dig('source_data', 'payload', 'headers')
            &.find { |item| item['name'] == 'Message-Id' }
            &.dig('value')
        elsif connection.microsoft?
          message_sent_session
            .data_source_message_details
            .dig('source_data', 'internetMessageId')
        elsif connection.smtp?
          message_sent_session
            .data_source_message_details
            .dig('source_data', 'message_id')
        end
    end

    def inject_tracking!
      inject_open_message! if @options[:track_open_message]
      inject_click_link!   if @options[:track_click_link]

      nil
    end

    def inject_open_message!
      service = Tracking::OpenEmailUrlService.new(params: tracking_params)
      service.call
      return if service.result[:updated_body].blank?

      params[:mail_message_params][:body] = service.result[:updated_body]

      nil
    end

    def inject_click_link!
      service = Tracking::ClickEmailLinkService.new(params: tracking_params)
      service.call
      return if service.result[:updated_body].blank?

      params[:mail_message_params][:body] = service.result[:updated_body]

      nil
    end

    # @param[Hash]
    def tracking_params
      @tracking_params ||=
        { message_sent_session:,
          body: params[:mail_message_params][:body] }
    end
  end
end
