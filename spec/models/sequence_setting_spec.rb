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
  end
end
