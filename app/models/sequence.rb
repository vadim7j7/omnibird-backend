# frozen_string_literal: true

class Sequence < ApplicationRecord
  belongs_to :account
  belongs_to :user

  has_one :sequence_setting, dependent: :destroy
  has_many :sequence_stages, dependent: :destroy

  enum :status, %i[pending started paused]

  validates :name, presence: true
  validates :sequence_setting, presence: true
  validates :sequence_stages, length: { minimum: 1 }

  accepts_nested_attributes_for :sequence_setting, update_only: true
  accepts_nested_attributes_for :sequence_stages, allow_destroy: true
end
