# frozen_string_literal: true

class ContactSequenceActivity < ApplicationRecord
  belongs_to :contact_sequence

  enum :event_type, %i[sent clicked opened replied bounced paused completed failed_to_send archived restored]
end
