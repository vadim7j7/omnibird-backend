# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Microsoft::EmailDetailsService, type: :service) do
  let(:connection) { create(:microsoft_email_sender) }
  let(:params) { { subject: 'Test Subject', to: Faker::Internet.email } }
  let(:service) { described_class.new(connection:, params:) }
  let(:authorization) { "#{connection.credentials_parsed[:token_type]} #{connection.credentials_parsed[:access_token]}" }

  describe '#call!' do
    context 'when the subject and to parameters are provided' do
      let(:api_response) do
        { value: [
          { subject: params[:subject],
            toRecipients: [{ emailAddress: { address: params[:to] } }],
            sentDateTime: Faker::Date.backward(days: 1),
            bodyPreview: 'Test email content' }
          ] }
      end

      before do
        allow(HTTParty).to receive(:get).and_return(double(success?: true, parsed_response: api_response))
      end

      it 'validates the connection and returns email details' do
        service.call!

        expect(service.result[:source_data]).to eq(api_response[:value].first)
        expect(service.status).to be true
      end
    end

    context 'when the API returns an error response' do
      let(:error_response) do
        { error: { code: 'InvalidRequest', message: 'Invalid query parameter', innerError: { date: '2024-10-21T12:00:00Z' } } }
      end

      before do
        allow(HTTParty).to receive(:get).and_return(double(success?: false, parsed_response: error_response))
      end

      it 'handles the error response correctly' do
        service.call!

        expect(service.result[:error][:message]).to eq('Invalid query parameter')
        expect(service.status).to be false
      end
    end

    context 'when the subject is missing' do
      let(:params) { { to: 'recipient@example.com' } }

      it 'raises MissingMessageIdError for missing subject' do
        expect { service.call! }.to raise_error(Connections::Exceptions::MissingMessageIdError, 'identifier subject is missing')
      end
    end

    context 'when the to field is missing' do
      let(:params) { { subject: 'Test Subject' } }

      it 'raises MissingMessageIdError for missing recipient' do
        expect { service.call! }.to raise_error(Connections::Exceptions::MissingMessageIdError, 'identifier to is missing')
      end
    end

    context 'when the connection is invalid' do
      before do
        allow(connection).to receive(:email_sender?).and_return(false)
      end

      it 'raises WrongCategoryError for an invalid connection category' do
        expect { service.call! }.to raise_error(Connections::Exceptions::WrongCategoryError, "#{service.class.name} doesn't support #{connection.category}")
      end
    end
  end

  describe '#query' do
    it 'returns the correct query parameters' do
      expected_query = { '$top': Connections::Microsoft::EmailDetailsService::LIMIT, '$orderby': 'sentDateTime desc' }

      # Use `send` to access the private method
      query_params = service.send(:query)

      expect(query_params).to eq(expected_query)
    end
  end
end
