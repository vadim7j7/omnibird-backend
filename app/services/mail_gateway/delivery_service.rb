# frozen_string_literal: true

module MailGateway
  class DeliveryService < MailGateway::BaseService
    attr_reader :mailer_service

    private

    def call!
      call_handler { build_mailer_service! }
    end

    # @return[Hash]
    def providers
      @providers ||= {
        google: Connections::Google::SendEmailService,
        microsoft: Connections::Microsoft::SendEmailService
      }
    end

    # @return[Hash]
    def google_params
      { encoded_message: mailer_service.as_string,
        thread_id: params[:thread_id] }
    end

    # @return[Hash]
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
      service = klass.new(connection:, params: provider_params)
      service.call!

      @status = service.status
      @result = service.result

      nil
    end
  end
end
