# frozen_string_literal: true

class User < ApplicationRecord
  has_many :account_users, dependent: :destroy
  has_many :accounts, through: :account_users

  has_many :action_rules, dependent: :destroy
  has_many :connections, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :sequences, dependent: :destroy

  validates :email, presence: true, uniqueness: true
end
