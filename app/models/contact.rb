# frozen_string_literal: true

class Contact < ApplicationRecord
  before_validation :set_email_domain!, if: -> { email.present? }

  has_many :contact_sequences, dependent: :destroy

  validates :email, presence: true

  private

  def set_email_domain!
    domain = EmailService.instance.to_domain(email:)
    return if domain.blank?
    return if EmailService.instance.public_email_provider?(domain:)

    self.email_domain = domain
  end
end
