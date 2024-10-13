class Connection < ApplicationRecord
  enum category: %i[oauth email_sender]
  enum service: %i[google]
  enum status: %i[pending connected failed]

  validates :category, :service, presence: true
  validates :uuid_service, presence: true, if: -> { connected? }
  validates :uuid_service, uniqueness: { scope: %i[category service] }
end
