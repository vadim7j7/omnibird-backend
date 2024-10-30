# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(SequenceStage, type: :model) do
  let(:sequence) { create(:sequence) }
  let(:sequence_stage) { sequence.sequence_stages.sample }

  subject { sequence_stage }

  describe 'attributes' do
    it { is_expected.to respond_to(:stage_index) }
    it { is_expected.to respond_to(:subject) }
    it { is_expected.to respond_to(:template) }
    it { is_expected.to respond_to(:variables) }

    it { is_expected.to respond_to(:perform_in_unit) }
    it { is_expected.to respond_to(:perform_in_period) }
    it { is_expected.to respond_to(:perform_reason) }

    it { is_expected.to respond_to(:allowed_send_window_from) }
    it { is_expected.to respond_to(:allowed_send_window_to) }

    it { is_expected.to respond_to(:timezone) }
    it { is_expected.to respond_to(:send_in_thread) }

    it { is_expected.to respond_to(:deleted_at) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should belong_to(:sequence) }
    it { should have_many(:contact_sequence_stages).dependent(true) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:perform_in_period).with_values(hours: 0, days: 1, weeks: 2, months: 3).with_prefix(:perform_in) }
    it { is_expected.to define_enum_for(:perform_reason).with_values(on_scheduled: 0, prev_stage_not_replied: 1, prev_stage_not_opened: 2)}
  end

  describe 'validations' do
    it { is_expected.to be_valid }

    it 'is valid with valid attributes' do
      expect(sequence_stage).to be_valid
    end

    it 'is invalid without a subject' do
      sequence_stage.subject = nil
      expect(sequence_stage).to be_invalid
      expect(sequence_stage.errors[:subject]).to include("can't be blank")
    end

    it 'is invalid without a template' do
      sequence_stage.template = nil
      expect(sequence_stage).to be_invalid
      expect(sequence_stage.errors[:template]).to include("can't be blank")
    end

    it 'is valid without a timezone and delegates timezone from settings' do
      sequence_stage.timezone = nil
      expect(sequence_stage).to be_valid
      expect(sequence_stage.timezone).to eq(sequence.sequence_setting.timezone)
    end

    it 'is invalid with an unsupported timezone' do
      sequence_stage.timezone = 'Invalid/Timezone'
      expect(sequence_stage).to be_invalid
      expect(sequence_stage.errors[:timezone]).to include('is not included in the list')
    end

    describe 'TimeWindowValidator' do
      context 'when allowed_send_window_from is before allowed_send_window_to' do
        it 'is valid' do
          expect(sequence_stage).to be_valid
        end
      end

      context 'when allowed_send_window_from is after allowed_send_window_to' do
        it 'is invalid and adds an error to allowed_send_window_to' do
          sequence_stage.allowed_send_window_from = 2.hours.from_now
          sequence_stage.allowed_send_window_to = 1.hour.from_now
          expect(sequence_stage).to be_invalid
          expect(sequence_stage.errors[:allowed_send_window_to]).to include('must be after allowed send window from')
        end
      end
    end
  end

  describe '#default_timezone!' do
    it 'sets the default timezone before validation if timezone is blank' do
      sequence_stage.timezone = nil
      expect { sequence_stage.valid? }.to change { sequence_stage.timezone }.from(nil).to(sequence.sequence_setting.timezone)
    end

    it 'does not change the timezone if it is already set' do
      sequence_stage.timezone = 'America/New_York'
      expect { sequence_stage.valid? }.not_to change { sequence_stage.timezone }
    end

    it 'defaults to America/Los_Angeles if sequence timezone is nil' do
      sequence.sequence_setting.timezone = nil
      sequence_stage.timezone = nil
      expect { sequence_stage.valid? }.to change { sequence_stage.timezone }.from(nil).to('America/Los_Angeles')
    end
  end
end
