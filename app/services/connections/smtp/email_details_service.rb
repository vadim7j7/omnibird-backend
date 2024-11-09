# frozen_string_literal: true

module Connections
  module Smtp
    class EmailDetailsService < Connections::BaseConnection
      prepend Connections::Helpers::EmailSenderCategory

      def call!
        validate!(provider: :smtp)
        validate_connection!

        @status = true
        @result[:source_data] = {
          id:         SecureRandom.uuid,
          message_id: params[:message_id],
          thread_id:  params[:thread][:id]
        }
      end
    end
  end
end
