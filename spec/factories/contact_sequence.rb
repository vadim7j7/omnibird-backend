# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :contact_sequence do
    association :contact
    association :sequence
    association :connection

    variables do
      { first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name }
    end

    status { :queued }
  end
end
