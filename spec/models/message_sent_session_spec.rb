# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(MessageSentSession, type: :model) do
  let!(:message_sent_session) { build(:message_sent_session) }

  subject { message_sent_session }

  describe 'attributes' do
    it { is_expected.to respond_to(:message_id) }
    it { is_expected.to respond_to(:thread_id) }
    it { is_expected.to respond_to(:mail_id) }
    it { is_expected.to respond_to(:stage) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:data_source_response) }
    it { is_expected.to respond_to(:data_source_message_details) }
    it { is_expected.to respond_to(:raw_message) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should belong_to(:connection) }
    it { should have_many(:contact_sequence_stages).dependent(true) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:stage).with_values(init: 0, sent: 1, retrieve: 2)}
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, completed: 1, failed: 2)}
  end
end
