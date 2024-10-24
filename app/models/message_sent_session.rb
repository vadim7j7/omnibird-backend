# frozen_string_literal: true

class MessageSentSession < ApplicationRecord
  belongs_to :connection

  enum :stage, %i[init sent retrieve]
  enum :status, %i[pending completed failed]
end
