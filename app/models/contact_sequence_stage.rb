# frozen_string_literal: true

class ContactSequenceStage < ApplicationRecord
  belongs_to :contact_sequence
  belongs_to :sequence_stage
  belongs_to :message_sent_session, optional: true

  has_many :contact_sequence_stage_activities, dependent: :destroy

  delegate :stage, to: :message_sent_session, allow_nil: true
  delegate :status, to: :message_sent_session, allow_nil: true
end
