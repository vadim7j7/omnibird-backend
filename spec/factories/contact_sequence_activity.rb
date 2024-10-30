# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :contact_sequence_activity do
    contact_sequence { build(:contact_sequence) }
    event_type { ContactSequenceActivity.event_types.keys.sample }
  end
end
