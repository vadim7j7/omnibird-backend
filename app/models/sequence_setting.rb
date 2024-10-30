# frozen_string_literal: true

class SequenceSetting < ApplicationRecord
  before_validation :default_timezone!, if: -> { timezone.blank? }

  belongs_to :sequence
  belongs_to :connection

  has_many :action_rule_associations, as: :action_rule_association_able, dependent: :destroy

  validates :timezone, presence: true, inclusion: { in: ActiveSupport::TimeZone::MAPPING.values }

  validates :cc_email, email_array: true
  validates :bcc_email, email_array: true

  validates_with TimeWindowValidator,
                 fields: {
                   allowed_send_window_from: :allowed_send_window_to,
                   skip_time_window_from: :skip_time_window_to
                 }
  validates_with WithinTimeValidator,
                 fields: {
                   outer_fields: %i[allowed_send_window_from allowed_send_window_to],
                   inner_fields: %i[skip_time_window_from skip_time_window_to]
                 }

  def default_timezone!
    self.timezone = 'America/Los_Angeles'
  end
end
