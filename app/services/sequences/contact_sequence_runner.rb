# frozen_string_literal: true

module Sequences
  class ContactSequenceRunner < ApplicationService
    attr_reader :contact_sequence
    attr_reader :sequence

    # @param[ContactSequence] contact_sequence
    def initialize(contact_sequence:, params: {})
      super(params:)

      @contact_sequence = contact_sequence
      @sequence         = contact_sequence.sequence
    end

    def call!; end
  end
end
