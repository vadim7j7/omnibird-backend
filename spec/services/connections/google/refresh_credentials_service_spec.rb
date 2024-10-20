# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Google::RefreshCredentialsService, type: :service) do
  let(:token_url) { 'https://www.googleapis.com/oauth2/v3/token' }
  let(:client_id) { ENV.fetch('SERVICE_GOOGLE_CLIENT_ID') }
  let(:client_secret) { ENV.fetch('SERVICE_GOOGLE_CLIENT_SECRET') }

  describe '#call!' do
    describe 'Sign in/up oAuth url' do
      let(:connection) { build(:google_oauth) }
      let(:service) { described_class.new(connection:) }

      it { expect { service.call! }.to raise_error(Connections::Exceptions::InvalidRefreshTokenError) }
    end

    describe 'Integration send email oAuth url' do
      let(:connection) { build(:google_email_sender) }
      let(:service) { described_class.new(connection:) }

      let(:token_response) do
        { 'access_token' => 'new_access_token',
          'token_type' => 'Bearer',
          'expires_in' => 3600,
          'refresh_token' => 'new_refresh_token' }
      end

      let(:http_success_response) do
        instance_double(HTTParty::Response, parsed_response: token_response, code: 200)
      end

      let(:http_failure_response) do
        instance_double(HTTParty::Response, parsed_response: { 'error' => 'invalid_grant' }, code: 400)
      end

      before do
        # Stub the HTTParty.post request
        allow(HTTParty).to receive(:post).with(
          token_url,
          body: hash_including(client_id:, client_secret:, refresh_token: connection.credentials_parsed[:refresh_token])
        ).and_return(http_success_response)
      end

      context 'when the refresh token is valid' do
        it 'makes a POST request to refresh the token and saves the response' do
          prev_refresh_token = connection.credentials_parsed[:refresh_token]

          service.call!

          # Check that the HTTParty.post request was made
          expect(HTTParty).to have_received(:post).with(
            token_url,
            body: hash_including(refresh_token: prev_refresh_token)
          )

          # Check that credentials are saved after success
          expect(service.credentials[:access_token]).to eq('new_access_token')
          expect(service.credentials[:refresh_token]).to eq('new_refresh_token')
        end
      end

      context 'when the refresh token is missing' do
        let(:connection) { build(:google_email_sender, credentials: { refresh_token: nil }) }

        it 'raises an InvalidRefreshTokenError' do
          expect { service.call! }.to raise_error(Connections::Exceptions::InvalidRefreshTokenError)
        end
      end

      context 'when the refresh token is invalid' do
        before do
          allow(HTTParty).to receive(:post).and_return(http_failure_response)
        end

        it 'handles the error and does not save credentials' do
          service.call!

          # Check that no credentials are saved on failure
          expect(service.credentials).to be_nil
        end
      end
    end
  end
end
