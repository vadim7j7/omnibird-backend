# frozen_string_literal: true

module FilteringUserAccountQuery
  extend ActiveSupport::Concern

  included do
    scope :by_user_and_account, lambda { |user:|
      # Builds a query to fetch records where the user is either directly associated
      # via `user_id` or indirectly associated through accounts they are linked to
      # in the `AccountUser` table.
      account_users_table = AccountUser.arel_table
      user_condition      = arel_table[:user_id].eq(user.id)
      account_condition   = arel_table[:account_id].in(
        account_users_table
          .project(account_users_table[:account_id])
          .where(account_users_table[:user_id].eq(user.id))
      )

      where(user_condition.or(account_condition))
    }
  end
end
