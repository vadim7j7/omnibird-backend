# frozen_string_literal: true

class ContactSequenceStage < ApplicationRecord
  belongs_to :connection
  belongs_to :contact_sequence
  belongs_to :sequence_stage
  belongs_to :message_sent_session
end
