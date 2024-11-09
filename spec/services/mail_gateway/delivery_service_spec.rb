# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(MailGateway::DeliveryService, type: :service) do
  let(:connection) { instance_double('Connection', provider: provider.to_s, email_sender?: true, token_able?: true) }
  let(:params) do
    { thread_id: Faker::Internet.uuid,
      mail_message_params: { subject: 'Test Subject',
                             body: 'Test Body' } }
  end
  let(:mailer_service) { instance_double('Message::MailerService', call: nil, status: true, as_string: 'encoded-message') }
  let(:service_instance) { described_class.new(connection:, params:) }

  before do
    allow(Message::MailerService).to receive(:new).and_return(mailer_service)
    allow(Utils::Token.instance).to receive(:check_and_refresh_token?).and_return(true)
  end

  describe '#call' do
    context 'when provider is Google' do
      let(:provider) { :google }
      let(:google_service) { instance_double('Connections::Google::SendEmailService', call!: nil, call: nil, status: true, result: 'success') }

      before do
        allow(Connections::Google::SendEmailService).to receive(:new).and_return(google_service)
      end

      it 'builds the mailer service and sends the email' do
        service_instance.call

        expect(Message::MailerService).to have_received(:new).with(params: params[:mail_message_params])
        expect(Connections::Google::SendEmailService).to have_received(:new).with(connection:, params: { encoded_message: 'encoded-message', thread_id: params[:thread_id] })
        expect(google_service).to have_received(:call!)
        expect(service_instance.status).to be_truthy
        expect(service_instance.result).to eq 'success'
      end
    end

    context 'when provider is Microsoft' do
      let(:provider) { :microsoft }
      let(:microsoft_service) { instance_double('Connections::Microsoft::SendEmailService', call!: nil, call: nil, status: true, result: 'success') }

      before do
        allow(Connections::Microsoft::SendEmailService).to receive(:new).and_return(microsoft_service)
      end

      it 'builds the mailer service and sends the email' do
        service_instance.call

        expect(Message::MailerService).to have_received(:new).with(params: params[:mail_message_params])
        expect(Connections::Microsoft::SendEmailService).to have_received(:new).with(connection:, params: { mailer_service: mailer_service })
        expect(microsoft_service).to have_received(:call!)
        expect(service_instance.status).to be_truthy
        expect(service_instance.result).to eq 'success'
      end
    end

    context 'when provider is SMTP' do
      let(:provider) { :smtp }
      let(:smtp_service) { instance_double('Connections::Smtp::SendEmailService', call!: nil, call: nil, status: true, result: 'success') }

      before do
        allow(Connections::Smtp::SendEmailService).to receive(:new).and_return(smtp_service)
      end

      it 'builds the mailer service and sends the email' do
        service_instance.call

        expect(Message::MailerService).to have_received(:new).with(params: params[:mail_message_params])
        expect(Connections::Smtp::SendEmailService).to(
          have_received(:new)
            .with(connection:, params: { mailer_service: mailer_service })
        )
        expect(smtp_service).to have_received(:call!)
        expect(service_instance.status).to be_truthy
        expect(service_instance.result).to eq 'success'
      end

      context 'when mailer service fails' do
        before do
          allow(mailer_service).to receive(:status).and_return(false)
          allow(mailer_service).to receive(:result).and_return({ error: 'Invalid email format' })
        end

        it 'returns the mailer service error' do
          service_instance.call

          expect(Connections::Smtp::SendEmailService).not_to have_received(:new)
          expect(service_instance.status).to be_falsey
          expect(service_instance.result).to eq({ error: 'Invalid email format' })
        end
      end

      context 'when smtp service fails' do
        before do
          allow(smtp_service).to receive(:status).and_return(false)
          allow(smtp_service).to receive(:result).and_return({ error: 'SMTP authentication failed' })
        end

        it 'returns the smtp service error' do
          service_instance.call

          expect(service_instance.status).to be_falsey
          expect(service_instance.result).to eq({ error: 'SMTP authentication failed' })
        end
      end
    end

    context 'when mailer service fails' do
      let(:provider) { :google }

      before do
        allow(mailer_service).to receive(:status).and_return(false)
        allow(mailer_service).to receive(:result).and_return({ error: 'Mailer failed' })
      end

      it 'sets the status to false and returns the mailer service result' do
        service_instance.call

        expect(service_instance.status).to be_falsey
        expect(service_instance.result).to eq({ error: 'Mailer failed' })
      end
    end

    context 'when token refresh fails' do
      let(:provider) { :google }

      before do
        allow(Utils::Token.instance).to receive(:check_and_refresh_token?).and_return(false)
      end

      it 'raises an InvalidRefreshTokenError and returns false' do
        service_instance.call

        expect(service_instance.status).to be_falsey
        expect(service_instance.result[:errors][:messages]).to include('access token is invalid')
      end
    end

    context 'when provider is unsupported' do
      let(:provider) { :unsupported }

      it 'returns an error' do
        service_instance.call
        expect(service_instance.status).to be_falsey
        expect(service_instance.result[:errors][:messages]).to include('unsupported is not supported')
      end
    end
  end
end
