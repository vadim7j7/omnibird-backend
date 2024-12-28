# frozen_string_literal: true

class ContactSequence < ApplicationRecord
  belongs_to :contact
  belongs_to :sequence
  belongs_to :connection

  has_many :contact_sequence_stages, dependent: :destroy

  enum :status, %i[queued active paused exited bounced]

  accepts_nested_attributes_for :contact, update_only: true
end
