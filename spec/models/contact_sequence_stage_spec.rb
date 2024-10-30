# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ContactSequenceStage, type: :model) do
  let(:contact_sequence_stage) { build(:contact_sequence_stage) }

  subject { contact_sequence_stage }

  describe 'attributes' do
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should belong_to(:connection) }
    it { should belong_to(:contact_sequence) }
    it { should belong_to(:sequence_stage) }
    it { should belong_to(:message_sent_session) }
  end
end
