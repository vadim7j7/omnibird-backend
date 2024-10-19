# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Google::RefreshProfileService, type: :service) do
  let(:profile_url) { 'https://www.googleapis.com/oauth2/v1/userinfo' }

  let(:connection) { create(:google_email_sender) }
  let(:service) { described_class.new(connection:) }

  describe '#call!' do
    context 'when access token is valid and user info is successfully retrieved' do
      let(:response_data) do
        { 'id' => 'user123',
          'picture' => 'avatar_url',
          'email' => 'user@example.com',
          'given_name' => 'John',
          'family_name' => 'Doe' }
      end

      before do
        allow(HTTParty)
          .to(
            receive(:get)
              .with(profile_url, headers: service.send(:headers))
              .and_return(double(code: 200, parsed_response: response_data))
          )

        allow(connection).to receive(:uuid=)
        allow(service).to receive(:success_connected!)
      end

      it 'fetches and saves user profile data from Google API' do
        service.call!

        expect(HTTParty).to have_received(:get).with(profile_url, headers: service.send(:headers))
        expect(connection).to have_received(:uuid=).with(response_data['id'])

        expect(service).to have_received(:success_connected!).with(
          credentials: service.credentials,
          source_data: {
            avatar: response_data['picture'],
            email: response_data['email'],
            first_name: response_data['given_name'],
            last_name: response_data['family_name']
          }
        )
      end
    end

    context 'when access token is invalid or expired' do
      let(:response_data) do
        { 'error' => { 'message' => 'Invalid Token' } }
      end

      before do
        allow(HTTParty).to(
          receive(:get)
            .and_return(double(code: 401, parsed_response: response_data))
        )
        allow(service).to receive(:error!)
      end

      it 'handles the error response from Google API' do
        service.call!

        expect(HTTParty).to have_received(:get)
        expect(service).to have_received(:error!).with(data: { user_info: response_data['error']['message'] })
      end
    end
  end
end
