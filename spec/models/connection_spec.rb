# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connection, type: :model) do
  describe 'Attributes' do
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
  end

  describe 'Enums' do
    let!(:connection) { build(:connection) }

    subject { connection }

    it { is_expected.to define_enum_for(:category).with_values(oauth: 0, email_sender: 1)}
    it { is_expected.to define_enum_for(:provider).with_values(google: 0, microsoft: 1)}
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, connected: 1, failed: 2)}
  end

  describe 'Google oAuth' do
    let!(:connection) { create(:google_oauth) }

    subject { connection }

    it { is_expected.to be_valid }
  end

  describe 'Google Email Sender' do
    let!(:connection) { create(:google_email_sender) }

    subject { connection }

    it { is_expected.to be_valid }
  end
end
