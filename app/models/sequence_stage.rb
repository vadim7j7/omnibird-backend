# frozen_string_literal: true

class SequenceStage < ApplicationRecord
  before_validation :default_timezone!, if: -> { timezone.blank? }

  belongs_to :sequence
  has_many :contact_sequence_stages, dependent: :destroy

  enum :perform_in_period, %i[hours days weeks months], prefix: :perform_in
  enum :perform_reason, %i[on_scheduled prev_stage_not_replied prev_stage_not_opened]

  validates :subject, :template, presence: true
  validates :timezone, presence: true, inclusion: { in: ActiveSupport::TimeZone::MAPPING.values }

  validates_with TimeWindowValidator,
                 fields: { allowed_send_window_from: :allowed_send_window_to }

  def default_timezone!
    self.timezone = sequence&.sequence_setting&.timezone || 'America/Los_Angeles'
  end
end
