# frozen_string_literal: true

class ContactSequence < ApplicationRecord
  belongs_to :contact
  belongs_to :sequence

  has_many :contact_sequence_stages, dependent: :destroy
  has_many :contact_sequence_activities, dependent: :destroy

  enum :status, %i[queued active paused exited bounced]
end
