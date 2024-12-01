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

        # Handler exceptions from ActiveRecord
        rescue_from(ActiveRecord::RecordInvalid) do |exp|
          data = HandlerExceptions.build_result(
            exp,
            message: exp.message,
            errors: exp.record.respond_to?(:errors) ? exp.record.errors.messages : {}
          )
          error!(data, 422)
        end

        rescue_from(ActiveRecord::RecordNotFound) do |exp|
          message = Rails.env.production? ? 'Not Found' : exp.message
          error!(HandlerExceptions.build_result(exp, message:), 404)
        end

        rescue_from ActiveRecord::RecordNotUnique do |exp|
          error!(HandlerExceptions.build_result(exp), 400)
        end

        # Handler exceptions from Grape
        rescue_from(Grape::Exceptions::ValidationErrors) do |exp|
          errors = {}
          exp.each do |attributes, error|
            key = attributes.last
            errors[key] = [] if errors[key].nil?
            errors[key] << error.message
          end

          message = exp.full_messages.to_sentence
          error!(HandlerExceptions.build_result(exp, message:, errors:), 422)
        end
      end

      # @param[String] message
      # @param[Hash] errors
      # @return[Hash]
      def self.build_result(exp, reason: nil, message: nil, errors: {}, meta: {})
        { meta:,
          reason: reason || :unknown,
          errors: errors || {},
          message: message || exp.message,
          with: Entities::ErrorEntity }
      end
    end
  end
end
