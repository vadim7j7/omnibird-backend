# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :contact_sequence_stage do
    association :connection
    association :contact_sequence
    association :sequence_stage
    association :message_sent_session
  end
end
