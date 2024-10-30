# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ContactSequence, type: :model) do
  let(:contact_sequence) { build(:contact_sequence) }

  subject { contact_sequence }

  describe 'attributes' do
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:variables) }
    it { is_expected.to respond_to(:scheduled_at) }
    it { is_expected.to respond_to(:archived_at) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should belong_to(:contact) }
    it { should belong_to(:sequence) }
    it { should have_many(:contact_sequence_stages).dependent(true) }
    it { should have_many(:contact_sequence_activities).dependent(true) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(queued: 0, active: 1, paused: 2, exited: 3, bounced: 4)}
  end

  describe 'validations' do
    it { is_expected.to be_valid }
  end
end
