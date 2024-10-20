# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Microsoft::RefreshProfileService, type: :service) do
  let(:profile_url) { 'https://graph.microsoft.com/v1.0/me' }
  let(:avatar_url) { 'https://graph.microsoft.com/v1.0/me/photo/$value' }

  let(:connection) { create(:microsoft_email_sender) }
  let(:service) { described_class.new(connection:) }

  describe '#call!' do
    context 'when access token is valid and user info is successfully retrieved' do
      let(:response_data) do
        { 'id' => 'user123',
          'mail' => 'user@example.com',
          'givenName' => 'John',
          'surname' => 'Doe' }
      end

      let(:avatar_data) { 'fake_avatar_image_data' }

      before do
        allow(HTTParty)
          .to(
            receive(:get)
              .with(profile_url, headers: service.send(:headers))
              .and_return(double(code: 200, parsed_response: response_data))
          )

        allow(HTTParty)
          .to(
            receive(:get)
              .with(avatar_url, headers: service.send(:headers))
              .and_return(double(success?: true, body: avatar_data))
          )

        allow(connection).to receive(:uuid=)
        allow(connection).to receive(:save)
        allow(service).to receive(:success_connected!)
      end

      it 'fetches and saves user profile data from Microsoft API' do
        service.call!

        expect(HTTParty).to have_received(:get).with(profile_url, headers: service.send(:headers))
        expect(HTTParty).to have_received(:get).with(avatar_url, headers: service.send(:headers))
        expect(connection).to have_received(:uuid=).with(response_data['id'])

        expect(service).to have_received(:success_connected!).with(
          credentials: service.credentials,
          source_data: {
            avatar: nil,
            email: response_data['mail'],
            first_name: response_data['givenName'],
            last_name: response_data['surname']
          }
        )

        expect(connection.provider_source_data['avatar_base64']).to eq(Base64.encode64(avatar_data))
      end
    end
  end
end
