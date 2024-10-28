# frozen_string_literal: true

class SequenceStage < ApplicationRecord
  belongs_to :sequence

  has_many :contact_sequence_stages, dependent: :destroy

  enum :perform_in_period, %i[hours days weeks months], prefix: :perform_in
  enum :perform_reason, %i[not_replied not_opened],
       prefix: :prev_stage
end
