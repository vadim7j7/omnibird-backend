# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ContactSequenceStageActivity, type: :model) do
  let(:contact_sequence_stage_activity) { build(:contact_sequence_stage_activity) }

  subject { contact_sequence_stage_activity }

  describe 'attributes' do
    it { is_expected.to respond_to(:event_type) }
    it { is_expected.to respond_to(:event_metadata) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should belong_to(:contact_sequence_stage) }
  end

  describe 'enums' do
    it do
      is_expected.to define_enum_for(:event_type).with_values(
        sent: 0, clicked: 1, opened: 2, replied: 3, bounced: 4, paused: 5,
        completed: 6, failed_to_send: 7, archived: 8, restored: 9
      )
    end
  end
end
