# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Utils::Token, type: :service) do
  let(:google_connection) { instance_double('Connection', provider: 'google', expired?: expired) }
  let(:microsoft_connection) { instance_double('Connection', provider: 'microsoft', expired?: expired) }
  let(:invalid_connection) { instance_double('Connection', provider: 'invalid', expired?: expired) }
  let(:expired) { false } # Set token as not expired by default
  let(:google_service) { instance_double('Connections::Google::RefreshCredentialsService', call!: nil, status: true) }
  let(:microsoft_service) { instance_double('Connections::Microsoft::RefreshCredentialsService', call!: nil, status: true) }

  before do
    allow(Connections::Google::RefreshCredentialsService).to receive(:new).and_return(google_service)
    allow(Connections::Microsoft::RefreshCredentialsService).to receive(:new).and_return(microsoft_service)
  end

  describe '#check_and_refresh_token?' do
    context 'when token is not expired and force_refresh is false' do
      it 'returns true without refreshing the token' do
        result = described_class.instance.check_and_refresh_token?(connection: google_connection)
        expect(result).to be true
        expect(Connections::Google::RefreshCredentialsService).not_to have_received(:new)
      end
    end

    context 'when token is expired' do
      let(:expired) { true }

      it 'refreshes the token for a Google connection' do
        result = described_class.instance.check_and_refresh_token?(connection: google_connection)
        expect(result).to be true
        expect(google_service).to have_received(:call!)
      end

      it 'refreshes the token for a Microsoft connection' do
        result = described_class.instance.check_and_refresh_token?(connection: microsoft_connection)
        expect(result).to be true
        expect(microsoft_service).to have_received(:call!)
      end

      it 'returns false if the provider is not supported' do
        result = described_class.instance.check_and_refresh_token?(connection: invalid_connection)
        expect(result).to be false
      end
    end

    context 'when force_refresh is true' do
      it 'forces a token refresh even if the token is not expired' do
        result = described_class.instance.check_and_refresh_token?(connection: google_connection, force_refresh: true)
        expect(result).to be true
        expect(google_service).to have_received(:call!)
      end
    end

    context 'when the refresh service fails' do
      let(:google_service) { instance_double('Connections::Google::RefreshCredentialsService', call!: nil, status: false) }

      it 'returns false when refresh fails' do
        result = described_class.instance.check_and_refresh_token?(connection: google_connection, force_refresh: true)
        expect(result).to be false
      end
    end

    context 'when InvalidRefreshTokenError is raised' do
      before do
        allow(google_service).to receive(:call!).and_raise(Connections::Exceptions::InvalidRefreshTokenError)
      end

      it 'returns false' do
        result = described_class.instance.check_and_refresh_token?(connection: google_connection, force_refresh: true)
        expect(result).to be false
      end
    end
  end
end
