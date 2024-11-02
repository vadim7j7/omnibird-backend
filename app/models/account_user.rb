# frozen_string_literal: true

class AccountUser < ApplicationRecord
  belongs_to :account
  belongs_to :user

  enum :role, %i[admin member]
end
