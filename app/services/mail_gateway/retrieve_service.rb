# frozen_string_literal: true

module MailGateway
  class RetrieveService < MailGateway::BaseService
    private

    def call!
      call_handler
    end

    # @return[Hash]
    def providers
      @providers ||= {
        google: Connections::Google::EmailDetailsService,
        microsoft: Connections::Microsoft::EmailDetailsService
      }
    end

    # @return[Hash]
    def google_params
      @google_params ||= {
        message_id: params[:message_id]
      }
    end

    # @return[Hash]
    def microsoft_params
      @microsoft_params ||= {
        subject: params[:subject],
        to: params[:email]
      }
    end

    # @return[Hash]
    def smtp_params
      {}
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
