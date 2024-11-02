# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Account, type: :model) do
  describe 'individual account' do
    let(:account) { build(:individual_account) }

    subject { account }

    it { expect(account.individual?).to be_truthy }

    describe 'attributes' do
      it { is_expected.to respond_to(:name) }
      it { is_expected.to respond_to(:slug) }
      it { is_expected.to respond_to(:domain) }
      it { is_expected.to respond_to(:type_of_account) }
      it { is_expected.to respond_to(:created_at) }
      it { is_expected.to respond_to(:updated_at) }
    end

    describe 'associations' do
      it { should have_many(:account_users).dependent(true) }
      it { should have_many(:users).through(:account_users) }
      it { should have_many(:account_admins).class_name('AccountUser') }
      it { should have_many(:action_rules).dependent(true) }
      it { should have_many(:connections).dependent(true) }
      it { should have_many(:contacts).dependent(true) }
      it { should have_many(:sequences).dependent(true) }
    end

    describe 'enums' do
      it { is_expected.to define_enum_for(:type_of_account).with_values(individual: 0, company: 1)}
    end

    describe 'validations' do
      it { is_expected.to be_valid }

      context 'when name is not present' do
        before { account.name = '' }

        it { is_expected.not_to be_valid }
      end

      context 'when slug is not present' do
        before { account.slug = '' }

        it { is_expected.not_to be_valid }
      end

      context 'when domain is not present' do
        before { account.domain = '' }

        it { is_expected.to be_valid }
      end

      context 'when there is more than one user' do
        before { account.account_users = build_list(:account_user, 2) }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe 'company account' do
    let(:account) { build(:company_account) }

    subject { account }

    it { expect(account.company?).to be_truthy }

    describe 'validations' do
      it { is_expected.to be_valid }

      context 'when domain is not present' do
        before { account.domain = '' }

        it { is_expected.not_to be_valid }
      end

      context 'when there is more than one user' do
        before { account.account_users = build_list(:account_user, 5) }

        it { is_expected.to be_valid }
      end
    end
  end
end
