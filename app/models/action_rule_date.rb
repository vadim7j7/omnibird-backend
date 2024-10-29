# frozen_string_literal: true

class ActionRuleDate < ApplicationRecord
  belongs_to :action_rule

  # Validations for presence based on date type
  validates :name, :group_key, presence: true
  validate :ensure_date_fields_present

  validates :day, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 31 }, allow_nil: true
  validates :month, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 12 }, allow_nil: true
  validates :year, numericality: { only_integer: true }, allow_nil: true
  validates :week_day, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 7 }, allow_nil: true
  validates :week_ordinal,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 },
            allow_nil: true

  # Custom validation method to ensure valid combinations
  def ensure_date_fields_present
    return if [ day, month, week_day, week_ordinal, week_is_last_day ].any?(&:present?)

    errors.add(:base, 'At least one of day, month, week_day, week_ordinal, or week_is_last_day must be present')
  end
end
