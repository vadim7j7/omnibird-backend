# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Internal::V1::Endpoints::Sequences, type: :request) do
  let(:user) { create(:user_in_individual_account) }
  let(:account) { user.accounts.first }
  let(:sequence) { create(:sequence, account:, user:) }
  let(:another_account) { create(:account) }

  describe '#POST /sequences' do
    let(:connection) { create(:google_email_sender, user:, account:) }

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
        blank_stages: sequence_valid_params.merge(sequence_stages_attributes: nil),
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

            expect(json[:errors][:sequence_stages]).to include('minimum 1 sequence stages')
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

  describe '#GET /sequences/:id' do
    describe 'when a user is signed in' do
      it 'returns :ok status' do
        api_get("/sequences/#{sequence.id}", account:, user:)

        expect(response).to have_http_status :ok
      end

      it 'returns :not_found status' do
        api_get("/sequences/#{rand(9999...99999)}", account:, user:)

        expect(response).to have_http_status :not_found
      end
    end

    describe 'when a user is not signed in' do
      it 'returns :unauthorized status' do
        api_get("/sequences/#{sequence.id}", account:)

        expect(response).to have_http_status :unauthorized
      end
    end

    describe 'when a user has no access to the sequence' do
      pending "Not implemented yet #{__FILE__}"
    end
  end

  describe '#PATCH /sequences/:id' do
    let(:sequence_valid_params) do
      { name: Faker::Name.name }
    end

    let(:sequence_invalid_params) do
      { name: '' }
    end

    context 'when a user is signed in' do
      describe 'with valid params' do
        it 'returns :ok status' do
          api_patch("/sequences/#{sequence.id}", account:, user:, params: { sequence: sequence_valid_params })

          expect(response).to have_http_status :ok
          expect(json[:name]).to eq(sequence_valid_params[:name])
        end

        it 'returns :not_found status' do
          api_patch("/sequences/#{rand(9999...99999)}", account:, user:, params: {})

          expect(response).to have_http_status :not_found
        end
      end

      describe 'with invalid params' do
        it 'returns :unprocessable_content status' do
          api_patch("/sequences/#{sequence.id}", account:, user:, params: { sequence: sequence_invalid_params })

          expect(response).to have_http_status :unprocessable_content
          expect(json[:errors][:name]).to include("can't be blank")
        end
      end
    end

    describe 'when a user is not signed in' do
      it 'returns :unauthorized status' do
        api_patch("/sequences/#{sequence.id}", account:)

        expect(response).to have_http_status :unauthorized
      end
    end

    describe 'when a user has no access to the sequence' do
      pending "Not implemented yet #{__FILE__}"
    end
  end

  describe '#DELETE /sequences/:id' do
    let(:sequence) { create(:sequence, account:, user:) }

    describe 'when a user is signed in' do
      it 'returns :no_content status' do
        api_delete("/sequences/#{sequence.id}", account:, user:)

        expect(response).to have_http_status :no_content
      end
    end

    describe 'when a user is not signed in' do
      it 'returns :unauthorized status' do
        api_delete("/sequences/#{sequence.id}", account:)

        expect(response).to have_http_status :unauthorized
      end
    end

    describe 'when a user has no access to the sequence' do
      pending "Not implemented yet #{__FILE__}"
    end
  end
end
