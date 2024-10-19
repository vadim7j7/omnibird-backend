# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Message::MailerService, type: :service) do
  let(:params) do
    { from: 'sender@example.com',
      to: 'recipient@example.com',
      subject: 'Test Subject',
      body: 'This is a test email.',
      attachments: [Rails.root.join('spec', 'fixtures', 'files', 'email_attachment_1.txt').to_s] }
  end

  let(:service) { described_class.new(params: params, body_type: :html) }

  describe '#call' do
    context 'when all required params are provided' do
      before { service.call }

      it 'sets the correct email attributes' do
        expect(service.message.from).to eq(['sender@example.com'])
        expect(service.message.to).to eq(['recipient@example.com'])
        expect(service.message.subject).to eq('Test Subject')
        expect(service.message.message_id).to match(/^.+@mail\.example\.com$/)
      end

      it 'sets the correct body type' do
        expect(service.message.html_part.body.raw_source).to eq('This is a test email.')
      end

      it 'adds attachments' do
        expect(service.message.parts.count).to eq(2) # HTML part and 1 attachment
      end
    end

    context 'when subject is missing' do
      let(:params) { super().merge(subject: nil) }

      before { service.call }

      it 'sets a default subject' do
        expect(service.message.subject).to eq('No Subject')
      end
    end

    context 'when attachments are provided' do
      let(:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'email_attachment_1.txt').to_s }

      before do
        # Mock file existence
        allow(File).to receive(:exist?).with(file_path).and_return(true)
        allow(File).to receive(:read).with(file_path).and_return('FILE - 1')
        allow(MIME::Types).to receive(:type_for).with(file_path).and_return([MIME::Type.new('text/plain')])

        service.call
      end

      it 'adds the attachment to the email' do
        attachment = service.message.parts.last
        expect(attachment.content_type).to include('text/plain')
        expect(attachment.body.raw_source).to include(Base64.encode64('FILE - 1').sub("\n", ''))
      end
    end

    context 'when to is missing' do
      let(:params) { super().merge(to: nil) }

      it 'fails validation' do
        service.call
        expect(service.instance_variable_get(:@result)[:errors][:to]).to eq('cannot be blank')
      end
    end

    context 'when email is part of a thread' do
      let(:params) { super().merge(in_reply_to: 'message-id-1234@example.com', references: ['message-id-123@example.com']) }

      before { service.call }

      it 'sets the correct subject' do
        expect(service.message.subject).to eq("Re: #{params[:subject]}")
      end

      it 'sets the correct in_reply_to header' do
        expect(service.message.in_reply_to).to eq('message-id-1234@example.com')
      end

      it 'sets the correct references header' do
        expect(service.message.references).to eq(%w[message-id-123@example.com message-id-1234@example.com])
      end

      context 'when no references are provided' do
        let(:params) { super().merge(references: nil) }

        it 'only sets in_reply_to as reference' do
          expect(service.message.references).to eq('message-id-1234@example.com')
        end
      end
    end
  end

  describe '#as_string' do
    before { service.call }

    it 'returns the email as a base64-encoded string' do
      expect(service.as_string).to eq(Base64.urlsafe_encode64(service.message.to_s))
    end
  end

  describe '#message_id' do
    before { service.call }

    it 'generates a unique message ID' do
      expect(service.message.message_id).to match(/^.+@mail\.example\.com$/)
    end
  end
end
