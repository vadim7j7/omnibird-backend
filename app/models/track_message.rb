# frozen_string_literal: true

class TrackMessage < ApplicationRecord
  before_validation :generate_tracking_key!, on: :create

  belongs_to :message_sent_session

  enum :action_type, %i[open_message click_link]

  private

  def generate_tracking_key!
    self.tracking_key = Digest::SHA256.hexdigest("#{SecureRandom.alphanumeric}_#{SecureRandom.uuid}_#{Time.now.to_f}")
  end
end
