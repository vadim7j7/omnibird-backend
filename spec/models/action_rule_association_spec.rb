# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ActionRuleAssociation, type: :model) do
  let(:action_rule_association) { build(:action_rule_association) }

  subject { action_rule_association }

  describe 'attributes' do
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should belong_to(:action_rule) }
    it { should belong_to(:action_rule_association_able) }
  end
end
