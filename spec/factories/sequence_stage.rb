# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :sequence_stage do
    timezone { ActiveSupport::TimeZone::MAPPING.values.sample }

    subject { Faker::Lorem.sentence }
    template { Faker::Lorem.paragraphs }

    stage_index { 0 }

    allowed_send_window_from { '08:00AM' }
    allowed_send_window_to { '05:00PM' }
  end
end
