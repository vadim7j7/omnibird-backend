# frozen_string_literal: true

class Sequence < ApplicationRecord
  include FilteringUserAccountQuery

  belongs_to :account
  belongs_to :user

  has_one :sequence_setting, dependent: :destroy
  has_many :sequence_stages, dependent: :destroy
  has_many :contact_sequences, dependent: :destroy
  has_many :contacts, through: :contact_sequences

  has_one :connection, through: :sequence_setting

  enum :status, %i[pending started paused]

  validates :name, presence: true
  validates :sequence_setting, presence: true
  validates :sequence_stages, length: { minimum: 1, message: 'minimum 1 sequence stages' }

  accepts_nested_attributes_for :sequence_setting, update_only: true
  accepts_nested_attributes_for :sequence_stages, allow_destroy: true
end
