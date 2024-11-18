# frozen_string_literal: true

class MessageSentSession < ApplicationRecord
  belongs_to :connection

  has_many :contact_sequence_stages, dependent: :destroy
  has_many :track_messages, dependent: :destroy

  enum :stage, %i[init sent retrieve]
  enum :status, %i[pending completed failed]
end
