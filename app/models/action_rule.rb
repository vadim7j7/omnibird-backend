# frozen_string_literal: true

class ActionRule < ApplicationRecord
  belongs_to :account, optional: true
  belongs_to :user, optional: true

  has_many :action_rule_dates, dependent: :destroy
  has_many :action_rule_associations, dependent: :destroy

  enum :action_type, %i[sending skipping]

  validates :name, :group_key, presence: true
end
