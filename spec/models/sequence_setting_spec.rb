# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(SequenceSetting, type: :model) do
  let(:sequence) { create(:sequence) }
  let(:sequence_setting) { sequence.sequence_setting }

  subject { sequence_setting }

  describe 'attributes' do
    it { is_expected.to respond_to(:timezone) }
    it { is_expected.to respond_to(:schedule_start_at) }

    it { is_expected.to respond_to(:allowed_send_window_from) }
    it { is_expected.to respond_to(:allowed_send_window_to) }
    it { is_expected.to respond_to(:skip_time_window_from) }
    it { is_expected.to respond_to(:skip_time_window_to) }

    it { is_expected.to respond_to(:exit_on_sender_email_received) }
    it { is_expected.to respond_to(:exit_on_meeting_booked) }
    it { is_expected.to respond_to(:exit_all_same_domain) }
    it { is_expected.to respond_to(:exit_on_domain_reply) }

    it { is_expected.to respond_to(:tracking_opens) }
    it { is_expected.to respond_to(:tracking_clicks) }

    it { is_expected.to respond_to(:prevent_repeat_send) }
    it { is_expected.to respond_to(:prevent_multi_sequence_send) }
    it { is_expected.to respond_to(:prevent_repeat_send_in_groups) }

    it { is_expected.to respond_to(:cc_email) }
    it { is_expected.to respond_to(:bcc_email) }

    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:updated_at) }
  end

  describe 'associations' do
    it { should belong_to(:sequence) }
    it { should belong_to(:connection) }
    it { should have_many(:action_rule_associations).dependent(true) }
  end

  describe 'validations' do
    it { is_expected.to be_valid }

    describe 'timezone' do
      it 'is invalid with a timezone outside the allowed list' do
        sequence_setting.timezone = 'Invalid/Timezone'
        expect(sequence_setting).to be_invalid
        expect(sequence_setting.errors[:timezone]).to include('is not included in the list')
      end
    end

    describe 'EmailArrayValidator' do
      let(:valid_email_array) { %w[valid@example.com another@example.com] }
      let(:invalid_email_array) { %w[invalid_email valid@example.com] }

      context 'when there are invalid emails in cc_email' do
        it 'is invalid and adds an error to cc_email' do
          sequence_setting.cc_email = invalid_email_array
          expect(sequence_setting).to be_invalid
          expect(sequence_setting.errors[:cc_email]).to include('invalid_email is not a valid email')
        end
      end

      context 'when there are invalid emails in bcc_email' do
        it 'is invalid and adds an error to bcc_email' do
          sequence_setting.bcc_email = invalid_email_array
          expect(sequence_setting).to be_invalid
          expect(sequence_setting.errors[:bcc_email]).to include('invalid_email is not a valid email')
        end
      end
    end

    describe 'TimeWindowValidator' do
      context 'when allowed_send_window_from is after allowed_send_window_to' do
        it 'is invalid and adds an error to allowed_send_window_to' do
          sequence_setting.allowed_send_window_from = 2.hours.from_now
          sequence_setting.allowed_send_window_to = 1.hour.from_now
          expect(sequence_setting).to be_invalid
          expect(sequence_setting.errors[:allowed_send_window_to]).to include('must be after allowed send window from')
        end
      end

      context 'when skip_time_window_from or skip_time_window_to is blank' do
        it 'is invalid and adds errors to skip time fields with skip_time_window_to' do
          sequence_setting.skip_time_window_to = nil
          expect(sequence_setting).to be_invalid
          expect(sequence_setting.errors[:skip_time_window_to]).to include('cannot be blank')
        end

        it 'is invalid and adds errors to skip time fields with skip_time_window_from' do
          sequence_setting.skip_time_window_from = nil
          expect(sequence_setting).to be_invalid
          expect(sequence_setting.errors[:skip_time_window_from]).to include('cannot be blank')
        end
      end
    end

    describe 'WithinTimeValidator' do
      context 'when skip_time_window is within allowed_send_window' do
        it 'is valid' do
          expect(sequence_setting).to be_valid
        end
      end

      context 'when skip_time_window_from is before allowed_send_window_from' do
        it 'is invalid and adds an error to skip_time_window_from' do
          sequence_setting.skip_time_window_from = sequence_setting.allowed_send_window_from - 1.hour
          expect(sequence_setting).to be_invalid
          expect(sequence_setting.errors[:skip_time_window_from]).to include('must be after allowed_send_window_from')
        end
      end

      context 'when skip_time_window_to is after allowed_send_window_to' do
        it 'is invalid and adds an error to skip_time_window_to' do
          sequence_setting.skip_time_window_to = sequence_setting.allowed_send_window_to + 1.hour
          expect(sequence_setting).to be_invalid
          expect(sequence_setting.errors[:skip_time_window_to]).to include('must be before allowed_send_window_to')
        end
      end
    end
  end
end
