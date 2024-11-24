# frozen_string_literal: true

module Internal
  module V1
    module Helpers
      module AuthenticationHelpers
        extend Grape::API::Helpers

        # @return[User, NIlClass]
        def current_user
          @current_user
        end

        # @return[Boolean]
        def user_signed_in?
          !!@current_user
        end

        def authenticate
          authenticate!
        rescue ActiveRecord::RecordNotFound, Internal::V1::Exceptions::UnauthorizedError, JsonWebToken::DecodeError
          @current_user = nil
        end

        def authenticate!
          @current_user ||= find_user
          raise Internal::V1::Exceptions::UnauthorizedError, 'Unauthenticated' if @current_user.nil?

          nil
        end

        private

        # @return[String, NilClass]
        def access_token
          return @access_token if @access_token

          tmp = (headers['Authorization'] || headers['authorization'])&.split
          return if tmp.blank?
          return unless tmp.first.downcase == Constants::JWT_TOKEN_SCHEME

          @access_token = tmp.last
        end

        # @return[Hash, NilClass]
        def payload
          return if access_token.blank?
          return @payload if @payload

          @payload = JsonWebToken.instance.decode(access_token)
        end

        # @return[User]
        def find_user
          raise JsonWebToken::DecodeError if payload.blank?

          User.find_by!(id: payload[:id])
        end
      end
    end
  end
end
