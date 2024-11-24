# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :contact_sequence_stage_activity do
    contact_sequence_stage { build(:contact_sequence_stage) }
    event_type { ContactSequenceStageActivity.event_types.keys.sample }
  end
end
