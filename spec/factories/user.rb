# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }

    factory :user_in_individual_account do
      account_users { build_list(:account_user, 1, account: build(:individual_account)) }
    end

    factory :user_in_company_account do
      account_users { build_list(:account_user, 1, account: build(:company_account)) }
    end
  end
end
