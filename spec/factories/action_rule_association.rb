# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :action_rule_association do
    action_rule { create(:action_rule) }
    action_rule_association_able { create(:sequence).sequence_setting }
  end
end
