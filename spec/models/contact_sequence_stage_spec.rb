# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ContactSequenceStage, type: :model) do
  let(:contact_sequence_stage) { build(:contact_sequence_stage) }

  subject { contact_sequence_stage }

  describe 'attributes' do
    it { is_expected.to respond_to(:stage_snapshot) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should belong_to(:contact_sequence) }
    it { should belong_to(:sequence_stage) }
    it { should belong_to(:message_sent_session).optional(true) }
    it { should have_many(:contact_sequence_stage_activities).dependent(true) }
  end

  describe 'delegates' do
    it { is_expected.to respond_to(:stage) }
    it { is_expected.to respond_to(:status) }
  end
end
