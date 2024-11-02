# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(User, type: :model) do
  let(:user) { build(:user) }

  subject { user }

  describe 'attributes' do
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:first_name) }
    it { is_expected.to respond_to(:last_name) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should have_many(:account_users).dependent(true) }
    it { should have_many(:accounts).through(:account_users) }
    it { should have_many(:action_rules).dependent(true) }
    it { should have_many(:connections).dependent(true) }
    it { should have_many(:contacts).dependent(true) }
    it { should have_many(:sequences).dependent(true) }
  end

  describe 'validations' do
    it { is_expected.to be_valid }

    context 'when email is not present' do
      before { user.email = '' }

      it { is_expected.not_to be_valid }
    end
  end

  context 'user with individual account' do
    let(:user) { create(:user_in_individual_account) }

    subject { user }
  end

  context 'user with company account' do
    let(:user) { create(:user_in_company_account) }

    subject { user }

    it { expect(user.accounts.count).to eql(1) }
  end
end
