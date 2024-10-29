# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ActionRuleDate, type: :model) do
  let(:action_rule) { build(:action_rule_date) }

  subject { action_rule }

  describe 'Attributes' do
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:group_key) }
    it { is_expected.to respond_to(:day) }
    it { is_expected.to respond_to(:month) }
    it { is_expected.to respond_to(:year) }
    it { is_expected.to respond_to(:week_day) }
    it { is_expected.to respond_to(:week_ordinal) }
    it { is_expected.to respond_to(:week_is_last_day) }
  end

  describe 'Associations' do
    it { should belong_to(:action_rule) }
  end

  describe 'validations' do
    let(:action_rule) { create(:action_rule) }

    it 'is valid with valid attributes for a fixed date' do
      date = build(:action_rule_date, :fixed_date, action_rule: action_rule)
      expect(date).to be_valid
    end

    it 'is valid with valid attributes for an ordinal week date' do
      date = build(:action_rule_date, :ordinal_week_date, action_rule: action_rule)
      expect(date).to be_valid
    end

    it 'is valid with valid attributes for a last weekday date' do
      date = build(:action_rule_date, :last_weekday_date, action_rule: action_rule)
      expect(date).to be_valid
    end

    it 'is invalid without a name' do
      date = build(:action_rule_date, :fixed_date, action_rule: action_rule, name: nil)
      expect(date).not_to be_valid
      expect(date.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a group_key' do
      date = build(:action_rule_date, :fixed_date, action_rule: action_rule, group_key: nil)
      expect(date).not_to be_valid
      expect(date.errors[:group_key]).to include("can't be blank")
    end

    it 'is invalid with an out-of-range day' do
      date = build(:action_rule_date, :fixed_date, action_rule: action_rule, day: 32)
      expect(date).not_to be_valid
      expect(date.errors[:day]).to include('must be less than or equal to 31')
    end

    it 'is invalid with an out-of-range month' do
      date = build(:action_rule_date, :fixed_date, action_rule: action_rule, month: 13)
      expect(date).not_to be_valid
      expect(date.errors[:month]).to include('must be less than or equal to 12')
    end

    it 'is invalid with an out-of-range week_day' do
      date = build(:action_rule_date, :ordinal_week_date, action_rule: action_rule, week_day: 8)
      expect(date).not_to be_valid
      expect(date.errors[:week_day]).to include('must be less than or equal to 7')
    end

    it 'is invalid with an out-of-range week_ordinal' do
      date = build(:action_rule_date, :ordinal_week_date, action_rule: action_rule, week_ordinal: 6)
      expect(date).not_to be_valid
      expect(date.errors[:week_ordinal]).to include('must be less than or equal to 5')
    end

    context 'ensure_date_fields_present' do
      subject { build(:action_rule_date, action_rule: action_rule) }

      it 'is valid when at least one of day, month, week_day, week_ordinal, or week_is_last_day is present' do
        subject.day = 1
        expect(subject).to be_valid

        subject.day = nil
        subject.month = 1
        expect(subject).to be_valid

        subject.month = nil
        subject.week_day = 1
        expect(subject).to be_valid

        subject.week_day = nil
        subject.week_ordinal = 2
        expect(subject).to be_valid

        subject.week_ordinal = nil
        subject.week_is_last_day = true
        expect(subject).to be_valid
      end

      it 'is invalid when none of day, month, week_day, week_ordinal, or week_is_last_day are present' do
        # Clear all fields
        subject.day = nil
        subject.month = nil
        subject.week_day = nil
        subject.week_ordinal = nil
        subject.week_is_last_day = nil

        expect(subject).to_not be_valid
        expect(subject.errors[:base]).to include('At least one of day, month, week_day, week_ordinal, or week_is_last_day must be present')
      end
    end
  end
end
