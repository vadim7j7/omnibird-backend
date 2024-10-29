# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :action_rule_date do
    association :action_rule
    name { 'Sample Date' }
    group_key { :holiday }

    # Default to a fixed date type for simplicity
    day { 1 }
    month { 1 }

    trait :fixed_date do
      day { 1 }
      month { 1 }
    end

    trait :ordinal_week_date do
      day { nil }
      month { 1 }
      week_day { 1 }
      week_ordinal { 3 }
      week_is_last_day { nil }
    end

    trait :last_weekday_date do
      day { nil }
      month { 5 }
      week_day { 1 }
      week_ordinal { nil }
      week_is_last_day { true }
    end
  end
end
