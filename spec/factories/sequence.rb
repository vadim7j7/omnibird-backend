# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :sequence do
    name { Faker::Name.name }
    status { :pending }
    sequence_setting { build(:sequence_setting) }
    sequence_stages { FactoryBot.build_list(:sequence_stage, 2) }
  end
end
