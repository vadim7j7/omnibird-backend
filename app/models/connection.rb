# frozen_string_literal: true

class Connection < ApplicationRecord
  encrypts(:credentials)

  enum :category, %i[oauth email_sender]
  enum :service, %i[google]
  enum :status, %i[pending connected failed]

  validates :category, :service, presence: true
  validates :uuid_service, presence: true, if: -> { connected? }
  validates :uuid_service, uniqueness: { scope: %i[category service] }

  def credentials_parsed
    return {} if credentials.blank?

    @credentials_parsed ||= JSON.parse(credentials).deep_symbolize_keys
  rescue JSON::ParserError
    {}
  end
end
