# frozen_string_literal: true

class User < ApplicationRecord
  has_many :account_users, dependent: :destroy
  has_many :accounts, through: :account_users

  validates :email, presence: true, uniqueness: true
end
