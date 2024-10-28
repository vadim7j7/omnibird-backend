# frozen_string_literal: true

class SequenceSetting < ApplicationRecord
  belongs_to :sequence
  belongs_to :connection

  has_many :action_rule_associations, as: :action_rule_association_able, dependent: :destroy
end
