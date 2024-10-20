# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Microsoft::CredentialsService, type: :service) do
  let(:token_url) { 'https://login.microsoftonline.com/common/oauth2/v2.0/token' }
  let(:userinfo_url) { 'https://graph.microsoft.com/v1.0/me' }
  let(:avatar_url) { 'https://graph.microsoft.com/v1.0/me/photo/$value' }
  let(:client_id) { ENV.fetch('SERVICE_MICROSOFT_CLIENT_ID') }
  let(:client_secret) { ENV.fetch('SERVICE_MICROSOFT_CLIENT_SECRET') }

  let(:user_info_response) do
    { 'id' => Faker::Internet.uuid,
      'mail' => Faker::Internet.email,
      'givenName' => Faker::Name.first_name,
      'surname' => Faker::Name.last_name }
  end

  describe '#call!' do
    describe 'Sign in/up oAuth url' do
      let(:redirect_uri) { "#{ENV.fetch('APP_FULL_URI')}/auth/callback/microsoft" }
      let(:connection) { build(:microsoft_oauth, provider_source_data: {}, metadata: { oauth_params: { redirect_uri: } }) }
      let(:params) { { code: 'auth_code' } }
      let(:service) { described_class.new(connection:, params:) }

      let(:token_response) do
        { 'access_token' => 'mock_access_token',
          'token_type' => 'Bearer',
          'expires_in' => 3600,
          'refresh_token' => nil }
      end

      let(:authorization_headers) do
        { Authorization: "#{token_response['token_type']} #{token_response['access_token']}",
          'Content-Type': 'application/json' }
      end

      let(:http_token_success_response) do
        instance_double(HTTParty::Response, parsed_response: token_response, code: 200)
      end

      let(:http_user_info_success_response) do
        instance_double(HTTParty::Response, parsed_response: user_info_response, code: 200)
      end

      let(:http_avatar_success_response) do
        instance_double(HTTParty::Response, success?: true, code: 200, body: 'base64_image_data') # Adjust body for avatar response
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
          headers: authorization_headers
        ).and_return(http_user_info_success_response)

        # Mock GET request for avatar
        allow(HTTParty).to receive(:get).with(
          avatar_url,
          headers: authorization_headers
        ).and_return(http_avatar_success_response)
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
            headers: authorization_headers
          )

          # Check that the avatar fetch request was made
          expect(HTTParty).to have_received(:get).with(
            avatar_url,
            headers: authorization_headers
          )

          expect(service.credentials[:access_token]).to eq(token_response['access_token'])
          expect(service.credentials[:refresh_token]).to eq(token_response['refresh_token'])
          expect(connection.connected?).to be_truthy
          expect(connection.uuid).to eq(user_info_response['id'])
          expect(connection.provider_source_data['email']).to eq(user_info_response['mail'])
          expect(connection.provider_source_data['avatar_base64']).to eq(Base64.encode64(http_avatar_success_response.body)) # Check avatar data
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

      context 'when avatar fetch fails' do
        let(:http_avatar_failure_response) do
          instance_double(HTTParty::Response, parsed_response: { 'error' => { 'message' => 'ImageNotFound' } }, code: 404)
        end

        before do
          allow(HTTParty).to receive(:get).and_return(http_avatar_failure_response)
        end

        it 'handles when avatar fetch fails' do
          service.call!

          expect(connection.provider_source_data['avatar_base64']).to be_nil # Avatar data should not be saved
          expect(service.status).to be_falsy # Ensure connection isn't marked as failed
        end
      end
    end

    describe 'Integration send email oAuth url' do
      let(:redirect_uri) { "#{ENV.fetch('APP_FULL_URI')}/auth/callback/microsoft" }
      let(:connection) { build(:microsoft_email_sender, provider_source_data: {}, metadata: { oauth_params: { redirect_uri: } }) }
      let(:params) { { code: 'auth_code' } }
      let(:service) { described_class.new(connection:, params:) }

      let(:token_response) do
        { 'access_token' => 'mock_access_token',
          'token_type' => 'Bearer',
          'expires_in' => 3600,
          'refresh_token' => 'mock_refresh_token' }
      end

      let(:authorization_headers) do
        { Authorization: "#{token_response['token_type']} #{token_response['access_token']}",
          'Content-Type': 'application/json' }
      end

      let(:http_token_success_response) do
        instance_double(HTTParty::Response, parsed_response: token_response, code: 200)
      end

      let(:http_user_info_success_response) do
        instance_double(HTTParty::Response, parsed_response: user_info_response, code: 200)
      end

      let(:http_avatar_success_response) do
        instance_double(HTTParty::Response, success?: true, code: 200, body: 'base64_image_data') # Adjust body for avatar response
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
          headers: authorization_headers
        ).and_return(http_user_info_success_response)

        # Mock GET request for avatar
        allow(HTTParty).to receive(:get).with(
          avatar_url,
          headers: authorization_headers
        ).and_return(http_avatar_success_response)
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
            headers: authorization_headers
          )

          # Check that the avatar fetch request was made
          expect(HTTParty).to have_received(:get).with(
            avatar_url,
            headers: authorization_headers
          )

          expect(service.credentials[:access_token]).to eq(token_response['access_token'])
          expect(service.credentials[:refresh_token]).to eq(token_response['refresh_token'])
          expect(service.credentials[:access_token]).to be_present
          expect(service.credentials[:refresh_token]).to be_present

          expect(connection.credentials_parsed[:access_token]).to eq(token_response['access_token'])
          expect(connection.credentials_parsed[:refresh_token]).to eq(token_response['refresh_token'])
          expect(connection.credentials_parsed[:access_token]).to be_present
          expect(connection.credentials_parsed[:refresh_token]).to be_present

          expect(connection.connected?).to be_truthy
          expect(connection.uuid).to eq(user_info_response['id'])
          expect(connection.provider_source_data['email']).to eq(user_info_response['mail'])
          expect(connection.provider_source_data['avatar_base64']).to eq(Base64.encode64(http_avatar_success_response.body)) # Check avatar data
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

      context 'when avatar fetch fails' do
        let(:http_avatar_failure_response) do
          instance_double(HTTParty::Response, parsed_response: { 'error' => { 'message' => 'ImageNotFound' } }, code: 404)
        end

        before do
          allow(HTTParty).to receive(:get).and_return(http_avatar_failure_response)
        end

        it 'handles when avatar fetch fails' do
          service.call!

          expect(connection.provider_source_data['avatar_base64']).to be_nil # Avatar data should not be saved
          expect(service.status).to be_falsy # Ensure connection isn't marked as failed
        end
      end
    end
  end
end
