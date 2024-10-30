# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :sequence do
    name { Faker::Name.name }
    status { :pending }
    sequence_setting { build(:sequence_setting) }
  end
end
