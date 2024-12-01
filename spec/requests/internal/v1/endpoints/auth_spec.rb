# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Internal::V1::Endpoints::Auth, type: :request) do
  describe '#GET /auth' do
    let(:user) { create(:user_in_individual_account) }
    let(:account) { user.accounts.first }
    let(:another_account) { create(:account) }

    context 'when a user is signed in' do
      before { api_get('/auth', account:, user:) }

      it { expect(response).to have_http_status :ok }
      it { expect(json).to eq({ userId: user.id, accountId: account.id }) }
    end

    context 'when a user has no credentials' do
      before { api_get('/auth') }

      it { expect(response).to have_http_status :unauthorized }
    end

    context 'when a user has no access to an account' do
      before { api_get('/auth', account: another_account, user:) }

      it { expect(response).to have_http_status :forbidden }
    end
  end
end
