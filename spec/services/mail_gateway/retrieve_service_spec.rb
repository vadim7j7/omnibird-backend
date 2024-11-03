# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(MailGateway::RetrieveService, type: :service) do
  let(:connection) { instance_double('Connection', provider: provider.to_s, email_sender?: true, token_able?: true) }
  let(:params) do
    { message_id: Faker::Internet.uuid,
      subject: 'Test Subject',
      email: Faker::Internet.email }
  end

  let(:service_instance) { described_class.new(connection:, params:) }

  before do
    allow(Utils::Token.instance).to receive(:check_and_refresh_token?).and_return(true)
  end

  describe '#call' do
    context 'when provider is Google' do
      let(:provider) { :google }
      let(:google_service) { instance_double('Connections::Google::EmailDetailsService', call!: nil, status: true, result: { source_data: 'google-email-details' }) }

      before do
        allow(Connections::Google::EmailDetailsService).to receive(:new).and_return(google_service)
      end

      it 'retrieves email details from Google and sets source_data' do
        service_instance.call

        expect(Connections::Google::EmailDetailsService).to have_received(:new).with(connection:, params: { message_id: params[:message_id] })
        expect(google_service).to have_received(:call!)
        expect(service_instance.status).to be true
        expect(service_instance.result).to eq({ source_data: 'google-email-details' })
      end
    end

    context 'when provider is Microsoft' do
      let(:provider) { :microsoft }
      let(:microsoft_service) { instance_double('Connections::Microsoft::EmailDetailsService', call!: nil, status: true, result: { source_data: 'microsoft-email-details' }) }

      before do
        allow(Connections::Microsoft::EmailDetailsService).to receive(:new).and_return(microsoft_service)
      end

      it 'retrieves email details from Microsoft and sets source_data' do
        service_instance.call

        expect(Connections::Microsoft::EmailDetailsService).to have_received(:new).with(connection:, params: { subject: 'Test Subject', to: params[:email] })
        expect(microsoft_service).to have_received(:call!)
        expect(service_instance.status).to be true
        expect(service_instance.result).to eq({ source_data: 'microsoft-email-details' })
      end
    end

    context 'when token refresh fails' do
      let(:provider) { :google }

      before do
        allow(Utils::Token.instance).to receive(:check_and_refresh_token?).and_return(false)
      end

      it 'raises an InvalidRefreshTokenError and returns false with an error message' do
        service_instance.call

        expect(service_instance.status).to be_falsey
        expect(service_instance.result[:errors][:messages]).to include('access token is invalid')
      end
    end

    context 'when provider is unsupported' do
      let(:provider) { :unsupported }

      it 'raises a WrongProviderError returns false with an error message' do
        service_instance.call

        expect(service_instance.status).to be_falsey
        expect(service_instance.result[:errors][:messages]).to include('unsupported is not supported')
      end
    end
  end
end
