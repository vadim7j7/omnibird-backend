# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Google::CredentialsService, type: :service) do
  let(:token_url) { 'https://accounts.google.com/o/oauth2/token' }
  let(:userinfo_url) { 'https://www.googleapis.com/oauth2/v1/userinfo' }
  let(:client_id) { ENV.fetch('SERVICE_GOOGLE_CLIENT_ID') }
  let(:client_secret) { ENV.fetch('SERVICE_GOOGLE_CLIENT_SECRET') }

  describe 'Sign in/up oAuth url' do
    let(:redirect_uri) { "#{ENV.fetch('APP_FULL_URI')}/auth/callback/google" }

    let(:connection) { build(:google_oauth, provider_source_data: {}, metadata: { oauth_params: { redirect_uri: } }) }
    let(:params) { { code: 'auth_code' } }
    let(:service) { described_class.new(connection:, params:) }

    let(:token_response) do
      { 'access_token' => 'mock_access_token',
        'token_type' => 'Bearer',
        'expires_in' => 3600,
        'refresh_token' => nil }
    end

    let(:user_info_response) do
      { 'id' => Faker::Internet.uuid,
        'email' => Faker::Internet.email,
        'given_name' => Faker::Name.first_name,
        'family_name' => Faker::Name.last_name,
        'picture' => Faker::Avatar.image }
    end

    let(:authorization) { "#{token_response['token_type']} #{token_response['access_token']}" }

    let(:http_token_success_response) do
      instance_double(HTTParty::Response, parsed_response: token_response, code: 200)
    end

    let(:http_user_info_success_response) do
      instance_double(HTTParty::Response, parsed_response: user_info_response, code: 200)
    end

    before do
      # Mock HTTParty.post request for token exchange
      allow(HTTParty).to receive(:post).with(
        token_url,
        body: hash_including(client_id:, client_secret:, redirect_uri:, code: params[:code]),
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
      ).and_return(http_token_success_response)

      # Mock HTTParty.get request for user info
      allow(HTTParty).to receive(:get).with(
        userinfo_url,
        headers: { Authorization: authorization }
      ).and_return(http_user_info_success_response)
    end

    context 'when both requests are successful' do
      it 'makes the token exchange and user info requests and saves the response' do
        service.call!

        # Check that the HTTParty.post request was made for token exchange
        expect(HTTParty).to have_received(:post).with(
          token_url,
          body: hash_including(code: 'auth_code'),
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        )

        # Check that the HTTParty.get request was made for user info
        expect(HTTParty).to have_received(:get).with(
          userinfo_url,
          headers: { Authorization: authorization }
        )

        expect(service.credentials[:access_token]).to be_present
        expect(service.credentials[:refresh_token]).to be_nil
        expect(connection.connected?).to be_truthy
        expect(connection.uuid).to eq(user_info_response['id'])
        expect(connection.provider_source_data['email']).to eq(user_info_response['email'])
        expect(connection.credentials).to be_nil
        expect(connection.state_token).to be_nil
        expect(connection.expired_at).to be_present
      end
    end

    context 'when token exchange fails' do
      let(:http_failure_response) do
        instance_double(HTTParty::Response, parsed_response: { 'error_description' => 'Invalid Token' }, code: 400)
      end

      before do
        allow(HTTParty).to receive(:post).and_return(http_failure_response)
      end

      it 'returns an error when token exchange fails' do
        service.call!

        expect(connection.failed?).to be_truthy
        expect(connection.provider_errors['token']).to eq('Invalid Token')
      end
    end

    context 'when user info request fails' do
      let(:http_user_info_failure_response) do
        instance_double(HTTParty::Response, parsed_response: { 'error' => { 'message' => 'Invalid Token' } }, code: 401)
      end

      before do
        allow(HTTParty).to receive(:get).and_return(http_user_info_failure_response)
      end

      it 'returns an error when user info request fails' do
        service.call!

        expect(connection.failed?).to be_truthy
        expect(connection.provider_errors['user_info']).to eq('Invalid Token')
      end
    end
  end

  describe 'Integration send email oAuth url' do
    let(:redirect_uri) { "#{ENV.fetch('APP_FULL_URI')}/auth/callback/google" }

    let!(:connection) { build(:google_email_sender, provider_source_data: {}, metadata: { oauth_params: { redirect_uri: } }) }
    let(:params) { { code: 'auth_code' } }
    let(:service) { described_class.new(connection:, params:) }

    let(:token_response) do
      { 'access_token' => 'mock_access_token',
        'token_type' => 'Bearer',
        'expires_in' => 3600,
        'refresh_token' => 'mock_refresh_token' }
    end

    let(:user_info_response) do
      { 'id' => Faker::Internet.uuid,
        'email' => Faker::Internet.email,
        'given_name' => Faker::Name.first_name,
        'family_name' => Faker::Name.last_name,
        'picture' => Faker::Avatar.image }
    end

    let(:authorization) { "#{token_response['token_type']} #{token_response['access_token']}" }

    let(:http_token_success_response) do
      instance_double(HTTParty::Response, parsed_response: token_response, code: 200)
    end

    let(:http_user_info_success_response) do
      instance_double(HTTParty::Response, parsed_response: user_info_response, code: 200)
    end

    before do
      # Mock HTTParty.post request for token exchange
      allow(HTTParty).to receive(:post).with(
        token_url,
        body: hash_including(client_id:, client_secret:, redirect_uri:, code: params[:code]),
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
      ).and_return(http_token_success_response)

      # Mock HTTParty.get request for user info
      allow(HTTParty).to receive(:get).with(
        userinfo_url,
        headers: { Authorization: authorization }
      ).and_return(http_user_info_success_response)
    end

    context 'when both requests are successful' do
      it 'makes the token exchange and user info requests and saves the response' do
        service.call!

        # Check that the HTTParty.post request was made for token exchange
        expect(HTTParty).to have_received(:post).with(
          token_url,
          body: hash_including(code: 'auth_code'),
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        )

        # Check that the HTTParty.get request was made for user info
        expect(HTTParty).to have_received(:get).with(
          userinfo_url,
          headers: { Authorization: authorization }
        )

        expect(connection.credentials_parsed[:access_token]).to eq(token_response['access_token'])
        expect(connection.credentials_parsed[:refresh_token]).to eq(token_response['refresh_token'])
        expect(connection.connected?).to be_truthy
        expect(connection.uuid).to eq(user_info_response['id'])
        expect(connection.provider_source_data['email']).to eq(user_info_response['email'])
        expect(connection.state_token).to be_nil
        expect(connection.expired_at).to be_present
      end
    end

    context 'when token exchange fails' do
      let(:http_failure_response) do
        instance_double(HTTParty::Response, parsed_response: { 'error_description' => 'Invalid Token' }, code: 400)
      end

      before do
        allow(HTTParty).to receive(:post).and_return(http_failure_response)
      end

      it 'returns an error when token exchange fails' do
        service.call!

        expect(connection.failed?).to be_truthy
        expect(connection.provider_errors['token']).to eq('Invalid Token')
      end
    end

    context 'when user info request fails' do
      let(:http_user_info_failure_response) do
        instance_double(HTTParty::Response, parsed_response: { 'error' => { 'message' => 'Invalid Token' } }, code: 401)
      end

      before do
        allow(HTTParty).to receive(:get).and_return(http_user_info_failure_response)
      end

      it 'returns an error when user info request fails' do
        service.call!

        expect(connection.failed?).to be_truthy
        expect(connection.provider_errors['user_info']).to eq('Invalid Token')
      end
    end
  end
end
