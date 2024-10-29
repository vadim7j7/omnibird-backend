# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ActionRule, type: :model) do
  let(:action_rule) { build(:action_rule) }

  subject { action_rule }

  describe 'Attributes' do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:group_key) }
    it { is_expected.to respond_to(:action_type) }
    it { is_expected.to respond_to(:system_action) }
  end

  describe 'Associations' do
    it { should have_many(:action_rule_dates).dependent(true) }
    it { should have_many(:action_rule_associations).dependent(true) }
  end

  describe 'Enums' do
    it { is_expected.to define_enum_for(:action_type).with_values(sending: 0, skipping: 1)}
  end

  describe 'Validations' do
    it { is_expected.to be_valid }
  end
end
