# frozen_string_literal: true

class ActionRule < ApplicationRecord
  has_many :action_rule_dates, dependent: :destroy
  has_many :action_rule_associations, dependent: :destroy

  enum :action_type, %i[sending skipping]
end
