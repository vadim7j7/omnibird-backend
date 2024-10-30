# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(EmailService, type: :service) do
  let(:email_service) { EmailService.instance }

  describe '#to_domain' do
    context 'when a valid email is provided' do
      it 'returns the domain of the email in lowercase' do
        email = Faker::Internet.email
        expected_domain = email.split('@').last

        expect(email_service.to_domain(email:)).to eq(expected_domain)
      end
    end

    context 'when an invalid email is provided' do
      it 'returns nil if the email does not contain "@"' do
        email = 'InvalidEmail'

        expect(email_service.to_domain(email: email)).to eq(nil)
      end

      it 'returns nil if the email is blank' do
        email = ''

        expect(email_service.to_domain(email: email)).to eq(nil)
      end
    end
  end

  describe '#public_email_provider?' do
    let(:valid_email_provider_domain_file) { Rails.root.join('db/datasets/all_email_provider_domains.txt') }

    before do
      # Create a dummy domain file for testing purposes
      allow(File).to(
        receive(:readlines)
        .with(valid_email_provider_domain_file, chomp: true)
        .and_return(%w[gmail.com yahoo.com hotmail.com])
      )
    end

    context 'when a domain is provided' do
      it 'returns true for a public email provider' do
        domain = 'gmail.com'

        expect(email_service.public_email_provider?(domain:)).to be true
      end

      it 'returns false for a non-public email provider' do
        domain = Faker::Internet.domain_name

        expect(email_service.public_email_provider?(domain:)).to be false
      end
    end

    context 'when an email is provided' do
      it 'returns true for a public email provider' do
        email = Faker::Internet.email(domain: 'Yahoo.com')

        expect(email_service.public_email_provider?(email:)).to be true
      end

      it 'returns false for a non-public email provider' do
        email = Faker::Internet.email

        expect(email_service.public_email_provider?(email:)).to be false
      end
    end

    context 'when no domain or email is provided' do
      it 'returns false' do
        expect(email_service.public_email_provider?(domain: nil)).to be false
        expect(email_service.public_email_provider?(email: nil)).to be false
      end
    end
  end
end
