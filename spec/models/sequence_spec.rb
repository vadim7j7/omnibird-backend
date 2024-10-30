# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Sequence, type: :model) do
  let!(:sequence) { build(:sequence) }

  subject { sequence }

  describe 'attributes' do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'nested attributes' do
    context 'with sequence_setting' do
      it 'accepts nested attributes for sequence_setting' do
        sequence.attributes = {
          sequence_setting_attributes: {
            timezone: 'America/New_York'
          }
        }

        expect(sequence.sequence_setting).to be_present
        expect(sequence.sequence_setting.timezone).to eq('America/New_York')
      end

      it 'updates sequence_setting when sequence_setting_attributes are provided' do
        sequence.save!
        expect(sequence.sequence_setting).to be_present

        new_timezone    = ActiveSupport::TimeZone::MAPPING.values.sample
        before_timezone = sequence.sequence_setting.timezone
        new_timezone    = ActiveSupport::TimeZone::MAPPING.values.sample if new_timezone == before_timezone

        sequence.sequence_setting_attributes = { id: sequence.sequence_setting.id, timezone: new_timezone }
        sequence.save!

        expect(sequence.sequence_setting.timezone).not_to eq(before_timezone)
        expect(sequence.sequence_setting.timezone).to eq(new_timezone)
      end
    end

    context 'with sequence_stages' do
      it 'accepts nested attributes for sequence_stages' do
        sequence.sequence_stages = []
        sequence.attributes = {
          sequence_stages_attributes: [
            { subject: 'First Stage', template: 'Template 1' },
            { subject: 'Second Stage', template: 'Template 2' }
          ]
        }

        expect(sequence.sequence_stages.size).to eq(2)
        expect(sequence.sequence_stages.map(&:subject)).to contain_exactly('First Stage', 'Second Stage')
      end

      it 'allows destroying sequence_stages' do
        sequence.save!

        sequence_stage = sequence.sequence_stages.last

        sequence.attributes = {
          sequence_stages_attributes: [
            { id: sequence_stage.id, _destroy: true }
          ]
        }

        expect { sequence.save }.to change { SequenceStage.count }.by(-1)
      end
    end
  end

  describe 'associations' do
    it { should have_many(:sequence_stages).dependent(true) }
    it { should have_one(:sequence_setting).dependent(true) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, started: 1, paused: 2)}
  end

  describe 'validations' do
    it { is_expected.to be_valid }
  end
end
