# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Microsoft::SendEmailService, type: :service) do
  let(:send_email_url) { 'https://graph.microsoft.com/v1.0/me/sendMail' }
  let(:reply_email_url) { 'https://graph.microsoft.com/v1.0/me/messages/{messageId}/reply' }
  let(:connection) { create(:microsoft_email_sender) }
  let(:authorization) { "#{connection.credentials_parsed[:token_type]} #{connection.credentials_parsed[:access_token]}" }

  let(:params) do
    { from: 'sender@example.com',
      to: 'recipient@example.com',
      subject: 'Test Subject',
      body: '<h1>Hello World</h1>',
      attachments: [Rails.root.join('spec', 'fixtures', 'files', 'email_attachment_1.txt').to_s] }
  end

  let(:mailer_service) do
    service = Message::MailerService.new(params:, body_type: :html)
    service.call
    service
  end

  let(:service) { described_class.new(connection:, params: { mailer_service: }) }

  describe '#call!' do
    context 'when connection is valid and email is sent successfully' do
      before do
        allow(HTTParty).to receive(:post).and_return(double(success?: true))
      end

      it 'sends an email through the Microsoft Graph API' do
        service.call!

        expect(HTTParty).to have_received(:post).with(
          send_email_url,
          body: service.email_body_payload.to_json,
          headers: service.send(:headers)
        )
      end

      it 'sets status to true' do
        service.call!
        expect(service.status).to be_truthy
      end
    end

    context 'when the email is a reply' do
      let(:in_reply_to_id) { Faker::Internet.uuid }
      before do
        allow(HTTParty).to receive(:post).and_return(double(success?: true))
      end

      before do
        mailer_service.message.in_reply_to = in_reply_to_id
        service.call!
      end

      it 'uses the reply email URL' do
        expect(HTTParty).to have_received(:post).with(
          reply_email_url.sub('{messageId}', in_reply_to_id),
          body: service.email_body_payload.to_json,
          headers: service.send(:headers)
        )
      end
    end

    context 'when sending the email fails' do
      let(:failed_response) do
        { 'error' => {
          'code' => 'InvalidAuthenticationToken',
          'message' => 'The access token is invalid.',
          'errors' => [{'message': 'Token expired'}]
        } }
      end

      before do
        allow(HTTParty).to receive(:post).and_return(double(success?: false, parsed_response: failed_response))
      end

      it 'does not set status to true' do
        service.call!
        expect(service.status).to be_falsey
      end

      it 'sets result with the error message' do
        service.call!
        expect(service.result).to eq(failed_response.deep_symbolize_keys)
      end
    end
  end

  describe '#headers' do
    it 'generates the correct authorization headers' do
      expect(service.send(:headers))
        .to eq({ Authorization: authorization, 'Content-Type': 'application/json' })
    end
  end

  describe '#build_email_body!' do
    before do
      service.send(:build_email_body!)
    end

    it 'builds the email body payload correctly' do
      attachment_path = params[:attachments].first

      expect(service.email_body_payload).to(
        include(
          message: {
            subject: params[:subject],
            body: {
              contentType: 'HTML',
              content: params[:body]
            },
            toRecipients: [{ emailAddress: { address: params[:to] } }],
            attachments: [
              { '@odata.type': '#microsoft.graph.fileAttachment',
                contentType: 'text/plain',
                contentBytes: Base64.encode64(File.read(attachment_path)),
                name: File.basename(attachment_path) }
            ]
          },
          saveToSentItems: true
        )
      )
    end
  end
end
