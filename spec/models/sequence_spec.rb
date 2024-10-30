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
