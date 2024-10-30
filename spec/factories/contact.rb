# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :contact do
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
