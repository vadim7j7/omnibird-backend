# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Handlers::SendMailService, type: :service) do
  let(:connection) { create(:smtp_email_sender) }
  let(:params) do
    { mail_message_params: { from: Faker::Internet.email,
                             to: [Faker::Internet.email],
                             subject: 'Test Subject',
                             body: Faker::HTML.paragraph }, thread_id: 'thread-123' }
  end

  let(:service) { described_class.new(connection:, params:) }
  let(:message_sent_session) { service.message_sent_session }

  describe '#call!' do
    let(:delivery_service) { instance_double(MailGateway::DeliveryService) }
    let(:retrieve_service) { instance_double(MailGateway::RetrieveService) }

    let(:delivery_result) do
      { api_message: { id: 'msg-123' },
        api_request: { subject: 'Test Subject', to: ['recipient@example.com'] },
        thread: { id: 'thread-123', references: [] } }
    end

    let(:retrieve_result) do
      { source_data: { id: 'source-123',
                       message_id: '<msg-123@mail.example.com>',
                       thread_id: 'thread-123',
                       payload: { headers: [ { name: 'Message-Id', value: '<msg-123@mail.example.com>' } ] } } }
    end

    before do
      allow(MailGateway::DeliveryService).to receive(:new).and_return(delivery_service)
      allow(MailGateway::RetrieveService).to receive(:new).and_return(retrieve_service)

      allow(delivery_service).to receive(:call)
      allow(delivery_service).to receive(:status).and_return(true)
      allow(delivery_service).to receive(:result).and_return(delivery_result)
      allow(delivery_service).to receive(:mailer_service).and_return(
        instance_double('Message::MailerService', as_string: 'base64-encoded-message')
      )

      allow(retrieve_service).to receive(:call)
      allow(retrieve_service).to receive(:status).and_return(true)
      allow(retrieve_service).to receive(:result).and_return(retrieve_result)
    end

    it 'processes email sending and retrieval successfully' do
      service.call!

      expect(message_sent_session.status).to eq('completed')
      expect(message_sent_session.stage).to eq('retrieve')
      expect(message_sent_session.message_id).to eq('source-123')
      expect(message_sent_session.thread_id).to eq('thread-123')
      expect(message_sent_session.mail_id).to eq('<msg-123@mail.example.com>')
    end

    context 'when tracking is turned on' do
      let(:service) { described_class.new(connection:, params:, options: { track_open_message: true }) }

      it 'injects open email IMG tag' do
        service.call!

        email_body   = service.params[:mail_message_params][:body]
        tracking_key = service.message_sent_session.track_messages.last.tracking_key

        expect(email_body).to include("#{tracking_key}/1x1.png")
      end
    end

    context 'when sending fails' do
      before do
        allow(delivery_service).to receive(:status).and_return(false)
        allow(delivery_service).to receive(:result).and_return({ error: 'Failed to send' })
      end

      it 'marks the session as failed' do
        service.call!

        expect(message_sent_session.status).to eq('failed')
        expect(message_sent_session.data_source_response).to eq({ 'error' => 'Failed to send' })
      end
    end

    context 'when retrieval fails' do
      before do
        allow(retrieve_service).to receive(:status).and_return(false)
        allow(retrieve_service).to receive(:result).and_return({ 'error' => 'Failed to retrieve' })
      end

      it 'marks the session as failed' do
        service.call!

        expect(message_sent_session.status).to eq('failed')
      end
    end

    context 'with different email providers' do
      context 'with Google provider' do
        let(:connection) { create(:google_email_sender) }

        it 'extracts the correct mail_id from Google response' do
          service.call!

          expect(message_sent_session.mail_id).to eq('<msg-123@mail.example.com>')
        end
      end

      context 'with Microsoft provider' do
        let(:connection) { create(:microsoft_email_sender) }
        let(:retrieve_result) do
          { source_data: { id: 'source-123',
                           conversationId: 'thread-123',
                           internetMessageId: '<msg-123@mail.example.com>' } }
        end

        it 'extracts the correct mail_id from Microsoft response' do
          service.call!

          expect(message_sent_session.mail_id).to eq('<msg-123@mail.example.com>')
        end
      end

      context 'with SMTP provider' do
        let(:connection) { create(:smtp_email_sender) }
        let(:retrieve_result) do
          { source_data: { id: 'source-123',
                           thread_id: 'thread-123',
                           message_id: '<msg-123@mail.example.com>' } }
        end

        it 'extracts the correct mail_id from SMTP response' do
          service.call!

          expect(message_sent_session.mail_id).to eq('<msg-123@mail.example.com>')
        end
      end
    end
  end

  describe '#message_sent_session' do
    it 'creates a new message sent session' do
      expect(service.message_sent_session).to be_a(MessageSentSession)
      expect(service.message_sent_session.connection).to eq(connection)
    end
  end
end
