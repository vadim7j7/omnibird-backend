# frozen_string_literal: true

class ContactSequenceStageActivity < ApplicationRecord
  belongs_to :contact_sequence_stage

  enum :event_type, %i[sent clicked opened replied bounced paused completed failed_to_send archived restored]
end
