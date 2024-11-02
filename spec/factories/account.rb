# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :account do
    name { Faker::Hacker.ingverb }
    slug { Faker::Internet.slug }

    factory :individual_account do
      type_of_account { :individual }
    end

    factory :company_account do
      type_of_account { :company }
      domain { Faker::Internet.domain_name }
    end
  end
end
