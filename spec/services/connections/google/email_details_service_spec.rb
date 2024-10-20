# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Google::EmailDetailsService, type: :service) do
  let(:connection) { create(:google_email_sender) }
  let(:message_id) { Faker::Internet.uuid }
  let(:service) { described_class.new(connection:, params: { message_id: }) }
  let(:authorization) { "#{connection.credentials_parsed[:token_type]} #{connection.credentials_parsed[:access_token]}" }

  describe '#call!' do
    context 'when the message ID is provided' do
      let(:api_response) do
        { id: '192a86772385232a',
          threadId: '192a86772385232a',
          labelIds: ['SENT'],
          snippet: 'Hello',
          payload: {
            partId: '',
            mimeType: 'multipart/mixed',
            headers: [
              { name: 'Received', value: 'from ...' },
              { name: 'Date', value: 'Sun, 20 Oct 2024 01:30:04 -0400' },
              { name: 'To', value: 'email@gmail.com' }
            ],
            parts: [
              { partId: '0', mimeType: 'text/html', body: { size: 22, data: 'PHN0cm9uZz5IZWxsbzwvc3Ryb25nPg==' } }
            ]
          },
          sizeEstimate: 664 }
      end

      before do
        allow(HTTParty).to receive(:get).and_return(double(success?: true, parsed_response: api_response))
      end

      it 'validates the connection and returns email details' do
        service.call!

        expect(service.result[:source_data]).to eq(api_response.deep_symbolize_keys)
        expect(service.status).to be true
      end
    end

    context 'when the API returns an error response' do
      let(:error_response) do
        { 'error' => {
            'code' => 400,
            'message' => 'Invalid id value',
            'errors' => [{ 'message' => 'Invalid id value', 'domain' => 'global', 'reason' => 'invalidArgument' }],
            'status' => 'INVALID_ARGUMENT'
          } }
      end

      before do
        allow(HTTParty).to receive(:get).and_return(double(success?: false, parsed_response: error_response))
      end

      it 'handles the error response correctly' do
        service.call!

        expect(service.result[:source_data][:error][:message]).to eq('Invalid id value')
        expect(service.status).to be false
      end
    end

    context 'when the message ID is missing' do
      let(:service) { described_class.new(connection:, params: {}) }

      it 'raises MissingMessageIdError' do
        expect { service.call! }.to raise_error(Connections::Exceptions::MissingMessageIdError)
      end
    end

    context 'when the connection is invalid' do
      before do
        allow(connection).to receive(:email_sender?).and_return(false)
      end

      it 'raises WrongCategoryError' do
        expect { service.call! }.to raise_error(Connections::Exceptions::WrongCategoryError)
      end
    end
  end
end
