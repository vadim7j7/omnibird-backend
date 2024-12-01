# frozen_string_literal: true

module Internal
  module V1
    module HandlerExceptions
      extend ActiveSupport::Concern

      included do
        rescue_from(::JsonWebToken::ExpiredSignature) do |exp|
          error!(HandlerExceptions.build_result(exp), :unauthorized)
        end

        rescue_from(::JsonWebToken::DecodeError) do |exp|
          error!(HandlerExceptions.build_result(exp), :unauthorized)
        end

        rescue_from(Exceptions::AccountAccessError) do |exp|
          error!(HandlerExceptions.build_result(exp), :forbidden)
        end
      end

      # @param[String] message
      # @param[Array] errors
      # @return[Hash]
      def self.build_result(exp, reason: nil, message: nil, errors: [], meta: {})
        { meta:,
          reason: reason || :unknown,
          errors: errors || [],
          message: message || exp.message,
          with: Entities::ErrorEntity }
      end
    end
  end
end
