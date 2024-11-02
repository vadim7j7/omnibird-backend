# frozen_string_literal: true

class Account < ApplicationRecord
  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users
  has_many :account_admins,
           -> { where(role: :admin) },
           class_name: 'AccountUser',
           primary_key: :id,
           foreign_key: :account_id

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true

  validates :domain, presence: true, if: -> { company? }
  validates :domain, uniqueness: true, if: -> { company? }

  enum :type_of_account, %i[individual company]
end
