# frozen_string_literal: true

module Sequences
  class ContactSequenceAddContact < ApplicationService
    attr_reader :sequence, :contact

    # @param[Sequence] sequence
    def initialize(sequence:, params: {})
      super(params:)

      @sequence = sequence
      @contact  = nil
    end

    def call!
      find_or_create_contact!

      nil
    end

    private

    def find_or_create_contact!
      email = params[:contact].delete(:email)

      @contact = Contact.find_or_initialize_by(email:)
      @contact.assign_attributes(**params[:contact])
      @contact.save!

      nil
    end
  end
end
