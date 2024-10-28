# frozen_string_literal: true

class Sequence < ApplicationRecord
  has_many :sequence_stages, dependent: :destroy
  has_one :sequence_setting, dependent: :destroy

  enum status: %i[pending started pasued]
end
