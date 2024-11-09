# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Smtp::SendEmailService, type: :service) do
  let(:connection) { create(:smtp_email_sender) }
  let(:mailer_service) { instance_double(Message::MailerService) }
  let(:mail_message) { instance_double(Mail::Message) }
  let(:smtp_double) { instance_double(Net::SMTP) }

  let(:sender_email) { Faker::Internet.email }
  let(:recipient_email) { Faker::Internet.email }

  let(:params) { { mailer_service: mailer_service } }
  let(:service) { described_class.new(connection:, params:) }

  before do
    allow(mailer_service).to receive(:message).and_return(mail_message)
    allow(mail_message).to receive(:to_s).and_return('raw email content')
    allow(mail_message).to receive(:from).and_return([sender_email])
    allow(mail_message).to receive(:to).and_return([recipient_email])
    allow(mail_message).to receive(:message_id).and_return(Faker::Internet.uuid)
    allow(mail_message).to receive(:subject).and_return(Faker::Hacker.abbreviation)
    allow(mail_message).to receive(:references).and_return(nil)

    allow(Net::SMTP).to receive(:new).and_return(smtp_double)
    allow(smtp_double).to receive(:enable_starttls_auto)
    allow(smtp_double).to receive(:start).and_yield(smtp_double)
  end

  describe '#call!' do
    context 'when email is sent successfully' do
      before do
        allow(smtp_double).to receive(:send_message).and_return(true)
      end

      it 'sends the email via SMTP' do
        service.call!

        expect(smtp_double).to have_received(:send_message).with('raw email content', sender_email, [recipient_email])
        expect(service.status).to be true

        expect(service.result).to(
          eq({ api_message: { id: mailer_service.message.message_id } ,
               api_request: { subject: mailer_service.message.subject, to: mailer_service.message.to },
               thread: { id: mailer_service.message.message_id, references: [] } })
        )
      end

      it 'enables STARTTLS if specified in settings' do
        service.call!
        expect(smtp_double).to have_received(:enable_starttls_auto)
      end
    end

    context 'when SMTP authentication fails' do
      before do
        allow(smtp_double).to(
          receive(:start)
            .and_raise(Net::SMTPAuthenticationError.new('Invalid credentials'))
        )
      end

      it 'handles authentication errors' do
        service.call!

        expect(service.status).to be false
        expect(service.result).to eq({ error: 'SMTP authentication failed', details: 'Invalid credentials' })
      end
    end

    context 'when other SMTP errors occur' do
      before do
        allow(smtp_double).to receive(:start).and_raise(StandardError.new('Connection timeout'))
      end

      it 'handles general SMTP errors' do
        service.call!

        expect(service.status).to be false
        expect(service.result).to eq({ error: 'Failed to send email', details: 'Connection timeout' })
      end
    end

    context 'when connection validation fails' do
      let(:connection) { create(:google_email_sender) } # Wrong provider

      it 'raises a wrong provider error' do
        expect { service.call! }.to raise_error(Connections::Exceptions::WrongProviderError)
      end
    end

    context 'with missing mailer service' do
      let(:params) { {} }

      it 'raises an error when trying to send' do
        expect { service.call! }.to raise_error(Connections::Exceptions::MissingParamError)
      end
    end
  end
end
