# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :sequence_setting do
    connection { create(:google_email_sender) }

    timezone { ActiveSupport::TimeZone::MAPPING.values.sample }

    allowed_send_window_from { '08:00AM' }
    allowed_send_window_to { '05:00PM' }
    skip_time_window_from { '01:00PM' }
    skip_time_window_to { '02:00PM' }
  end
end
