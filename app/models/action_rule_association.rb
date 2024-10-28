# frozen_string_literal: true

class ActionRuleAssociation < ApplicationRecord
  belongs_to :action_rule
  belongs_to :action_rule_association_able, polymorphic: true
end
