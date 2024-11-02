# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :account_user do
    association :account
    association :user

    role { :admin }
  end
end
