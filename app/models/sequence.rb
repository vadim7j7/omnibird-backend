# frozen_string_literal: true

class Sequence < ApplicationRecord
  belongs_to :account
  belongs_to :user

  has_one :sequence_setting, dependent: :destroy
  has_many :sequence_stages, dependent: :destroy
  has_many :contact_sequences, dependent: :destroy

  enum :status, %i[pending started paused]

  validates :name, presence: true
  validates :sequence_setting, presence: true
  validates :sequence_stages, length: { minimum: 1 }

  accepts_nested_attributes_for :sequence_setting, update_only: true
  accepts_nested_attributes_for :sequence_stages, allow_destroy: true

  scope :by_user, lambda { |user|
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
