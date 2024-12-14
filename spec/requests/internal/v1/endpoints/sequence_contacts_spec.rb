# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Internal::V1::Endpoints::Sequences, type: :request) do
  let(:user) { create(:user_in_individual_account) }
  let(:account) { user.accounts.first }
  let(:sequence) { create(:sequence, account:, user:) }
  let(:another_account) { create(:account) }

  describe '#GET /sequences/:id/contacts' do
    before { create_list(:contact_sequence, 5, sequence:, connection: sequence.sequence_setting.connection) }

    describe 'when a user is signed in' do
      it 'returns 5 contacts' do
        api_get("/sequences/#{sequence.id}/contacts", account:, user:)

        expect(response).to have_http_status :ok
        expect(json[:contacts].count).to eq(5)
      end
    end
  end
end
