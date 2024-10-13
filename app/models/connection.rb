# frozen_string_literal: true

class Connection < ApplicationRecord
  encrypts(:credentials)

  enum :category, %i[oauth email_sender]
  enum :provider, %i[google]
  enum :status, %i[pending connected failed]

  validates :category, :provider, presence: true
  validates :uuid, presence: true, if: -> { connected? }
  validates :uuid, uniqueness: { scope: %i[category provider] }

  def credentials_parsed
    return {} if credentials.blank?

    @credentials_parsed ||= JSON.parse(credentials).deep_symbolize_keys
  rescue JSON::ParserError
    {}
  end
end
