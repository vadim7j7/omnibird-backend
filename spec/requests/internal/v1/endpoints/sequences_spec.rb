# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Internal::V1::Endpoints::Sequences, type: :request) do
  describe '#POST /sequences' do
    let(:user) { create(:user_in_individual_account) }
    let(:account) { user.accounts.first }
    let(:connection) { create(:google_email_sender, user:, account:) }
    let(:another_account) { create(:account) }

    let(:sequence_valid_params) do
      {
        name: Faker::Name.name,
        sequence_setting_attributes: {
          connection_id: connection.id,
          timezone: 'America/Los_Angeles',
        },
        sequence_stages_attributes: [
          { stage_index: 0,
            subject: Faker::Lorem.word,
            template: Faker::Lorem.word,
            perform_in_unit: 0,
            perform_in_period: :hours },
          { stage_index: 1,
            subject: '',
            template: Faker::Lorem.word,
            perform_in_unit: 5,
            perform_in_period: :days },
        ]
      }
    end

    let(:sequence_invalid_params) do
      { blank_name: sequence_valid_params.merge(name: ''),
        blank_stages: sequence_valid_params.merge(sequence_stages_attributes: []),
        nil_connection_id: sequence_valid_params.merge(
          sequence_setting_attributes: sequence_valid_params.merge(connection_id: nil)
        ) }
    end

    context 'when a user is signed in' do
      describe 'with valid params' do
        before { api_post('/sequences', account:, user:, params: { sequence: sequence_valid_params }) }

        it 'creates a new sequence' do
          expect(user.sequences.last.name).to eq(sequence_valid_params[:name])
          expect(account.sequences.last.name).to eq(sequence_valid_params[:name])
        end
      end

      context 'when params are invalid' do
        describe 'with blank name in params' do
          before { api_post('/sequences', account:, user:, params: { sequence: sequence_invalid_params[:blank_name] }) }

          it 'returns an error' do
            expect(response).to have_http_status :unprocessable_entity
            expect(json[:message]).to eq("Validation failed: Name can't be blank")
            expect(json[:errors]).to eq({ name: ["can't be blank"] })
          end
        end

        describe 'with blank stages in params' do
          before { api_post('/sequences', account:, user:, params: { sequence: sequence_invalid_params[:blank_stages] }) }

          it 'returns an error' do
            expect(response).to have_http_status :unprocessable_entity
            expect(json[:message]).to include('sequence[sequence_stages_attributes][0][subject] is missing')
            expect(json[:message]).to include('sequence[sequence_stages_attributes][0][template] is missing')
          end
        end

        describe 'with nil connection_id in params' do
          before { api_post('/sequences', account:, user:, params: { sequence: sequence_invalid_params[:nil_connection_id] }) }

          it 'returns an error' do
            expect(response).to have_http_status :unprocessable_entity
            expect(json[:message]).to eq('Validation failed: Sequence setting connection must exist')
            expect(json[:errors]).to eq({ :'sequence_setting.connection' => ['must exist'] })
          end
        end
      end
    end

    context 'when a user is not signed in' do
      before { api_post('/sequences', params: { sequence: sequence_valid_params }) }

      it { expect(response).to have_http_status :unauthorized }
    end

    context 'when a user has no access to an account' do
      before { api_post('/sequences', account: another_account, user:, params: { sequence: sequence_valid_params }) }

      it { expect(response).to have_http_status :forbidden }
    end
  end
end
