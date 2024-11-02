# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(AccountUser, type: :model) do
  let(:account_user) { build(:account_user) }

  subject { account_user }

  describe 'attributes' do
    it { is_expected.to respond_to(:role) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should belong_to(:account) }
    it { should belong_to(:user) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(admin: 0, member: 1)}
  end
end
