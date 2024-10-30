# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Contact, type: :model) do
  let(:contact) { build(:contact) }

  subject { contact }

  describe 'attributes' do
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:first_name) }
    it { is_expected.to respond_to(:last_name) }
    it { is_expected.to respond_to(:email_domain) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should have_many(:contact_sequences).dependent(true) }
  end

  describe 'validations' do
    it { is_expected.to be_valid }
  end

  describe 'callbacks' do
    context 'when email is valid' do
      before { contact.email = Faker::Internet.email }
      let(:domain) { contact.email.split('@').last }

      it 'sets the email_domain' do
        contact.valid? # Trigger validation
        expect(contact.email_domain).to eq(domain)
      end
    end

    context 'when email is valid but not a public provider' do
      before { contact.email = Faker::Internet.email(domain: 'gmail.com') }

      it 'does not set the email_domain' do
        contact.valid? # Trigger validation
        expect(contact.email_domain).to be_nil
      end
    end

    context 'when email is invalid' do
      before { contact.email = 'invalid_email' }

      it 'does not set the email_domain' do
        contact.valid? # Trigger validation
        expect(contact.email_domain).to be_nil
      end
    end

    context 'when email is blank' do
      before { contact.email = '' }

      it 'does not set the email_domain' do
        contact.valid? # Trigger validation
        expect(contact.email_domain).to be_nil
      end
    end
  end
end
