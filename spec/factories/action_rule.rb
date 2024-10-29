# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :action_rule do
    name { 'Holiday Rules' }
    group_key { :holiday }
    action_type { :skipping }
  end
end
