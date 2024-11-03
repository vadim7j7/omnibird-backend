# frozen_string_literal: true

class Connection < ApplicationRecord
  encrypts(:credentials)

  belongs_to :account
  belongs_to :user

  has_many :message_sent_sessions, dependent: :destroy
  has_many :sequence_settings, dependent: :destroy
  has_many :contact_sequence_stages, dependent: :destroy

  enum :category, %i[oauth email_sender]
  enum :provider, %i[google microsoft smtp]
  enum :status, %i[pending connected failed]

  validates :category, :provider, presence: true
  validates :uuid, presence: true, if: -> { connected? }
  validates :uuid, uniqueness: { scope: %i[category provider] }

  # @return[Hash]
  def credentials_parsed
    return {} if credentials.blank?

    JSON.parse(credentials).deep_symbolize_keys
  rescue JSON::ParserError
    {}
  end

  # @return[Boolean]
  def reconnect_able?
    credentials_parsed[:refresh_token].present?
  end

  # @return[Boolean]
  def expired?
    return true if expired_at.nil?

    Time.zone.now >= expired_at
  end
end
