# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connection, type: :model) do
  describe 'attributes' do
    let!(:connection) { build(:connection) }

    subject { connection }

    it { is_expected.to respond_to(:uuid) }
    it { is_expected.to respond_to(:category) }
    it { is_expected.to respond_to(:provider) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:credentials) }
    it { is_expected.to respond_to(:metadata) }
    it { is_expected.to respond_to(:provider_source_data) }
    it { is_expected.to respond_to(:provider_errors) }
    it { is_expected.to respond_to(:state_token) }
    it { is_expected.to respond_to(:expired_at) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    let!(:connection) { build(:connection) }

    subject { connection }

    it { should have_many(:message_sent_sessions).dependent(true) }
    it { should have_many(:sequence_settings).dependent(true) }
    it { should have_many(:contact_sequence_stages).dependent(true) }
  end

  describe 'enums' do
    let!(:connection) { build(:connection) }

    subject { connection }

    it { is_expected.to define_enum_for(:category).with_values(oauth: 0, email_sender: 1)}
    it { is_expected.to define_enum_for(:provider).with_values(google: 0, microsoft: 1, smtp: 2)}
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, connected: 1, failed: 2)}
  end

  describe 'google oAuth' do
    let!(:connection) { create(:google_oauth) }

    subject { connection }

    it { is_expected.to be_valid }
  end

  describe 'google email sender' do
    let!(:connection) { create(:google_email_sender) }

    subject { connection }

    it { is_expected.to be_valid }
  end
end
