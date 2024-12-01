# frozen_string_literal: true

module Internal
  module V1
    module Helpers
      module CurrentAccountHelpers
        extend Grape::API::Helpers

        # @return[Account]
        def current_account
          @current_account
        end

        # @return[AccountUser]
        def current_account_user
          @current_account_user
        end

        def load_account!
          raise Internal::V1::Exceptions::AccountAccessError if current_user.nil?

          load_current_account_user!
          raise Internal::V1::Exceptions::AccountAccessError if current_account_user.nil?

          @current_account = current_account_user.account

          nil
        end

        def load_account
          load_account!
        rescue ActiveRecord::RecordNotFound, Internal::V1::Exceptions::AccountAccessError
          nil
        end

        private

        def load_current_account_user!
          resource = current_user.account_users.includes(:account)
          @current_account_user =
            if account_value.blank? || account_value == 'me'
              resource.admin.find_by(account: { type_of_account: :individual })
            else
              resource.find_by(account_attrs)
            end

          nil
        end

        # @return[String]
        def account_value
          headers['X-Account'] || headers['x-account']
        end

        # @return[Hash]
        def account_attrs
          { account: { slug: account_value } }
        end
      end
    end
  end
end
