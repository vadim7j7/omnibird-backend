# frozen_string_literal: true

class TrackMessage < ApplicationRecord
  before_validation :generate_tracking_key!, on: :create

  belongs_to :message_sent_session

  enum :action_type, %i[open_message click_link]

  # @return[String]
  def url
    generate_tracking_key! if tracking_key.blank?

    "#{ENV.fetch('API_FULL_URI')}/v1/public/#{tracking_key}/1x1.png"
  end

  private

  def generate_tracking_key!
    return if tracking_key.present?

    self.tracking_key = Digest::SHA256.hexdigest("#{SecureRandom.alphanumeric}_#{SecureRandom.uuid}_#{Time.now.to_f}")
  end
end
