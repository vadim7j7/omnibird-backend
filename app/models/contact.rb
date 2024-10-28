# frozen_string_literal: true

class Contact < ApplicationRecord
  has_many :contact_sequences, dependent: :destroy

  validates :email, presence: true
end
