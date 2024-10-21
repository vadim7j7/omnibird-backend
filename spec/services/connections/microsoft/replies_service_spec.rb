# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Microsoft::RepliesService, type: :service) do\
  let(:connection) { create(:microsoft_email_sender) }
  let(:params) { { thread_id: Faker::Internet.uuid } }
  let(:service) { described_class.new(connection:, params:) }
  let(:authorization) { "#{connection.credentials_parsed[:token_type]} #{connection.credentials_parsed[:access_token]}" }
  let(:mail_subject) { Faker::Lorem.sentence(word_count: 3) }

  describe '#call!' do
    context 'when thread_id is provided' do
      let(:api_response) do
        { value: [
          { conversationId: params[:thread_id],
            subject: mail_subject,
            sentDateTime: Faker::Time.backward(days: 3).utc.iso8601,
            bodyPreview: Faker::Lorem.sentence(word_count: 5) },
          { conversationId: params[:thread_id],
            subject: "Re: #{mail_subject}",
            sentDateTime: Faker::Time.backward(days: 2).utc.iso8601,
            bodyPreview: Faker::Lorem.sentence(word_count: 5) },
          { conversationId: params[:thread_id],
            subject: "Re: #{mail_subject}",
            sentDateTime: Faker::Time.backward(days: 1).utc.iso8601,
            bodyPreview: Faker::Lorem.sentence(word_count: 5) }
        ] }
      end

      before do
        allow(HTTParty).to receive(:get).and_return(double(success?: true, parsed_response: api_response))
      end

      it 'returns replies sorted by sentDateTime' do
        service.call!

        expect(service.result[:source_data].first[:subject]).to eq("Re: #{mail_subject}")
        expect(service.result[:source_data].second[:subject]).to eq("Re: #{mail_subject}")
        expect(service.result[:source_data].size).to eq(api_response[:value].count - 1)
        expect(service.status).to be true
      end
    end

    context 'when the API returns an error response' do
      let(:error_response) do
        {
          error: {
            code: 'InvalidRequest',
            message: 'Invalid query parameter',
            innerError: { date: '2024-10-21T12:00:00Z' }
          }
        }
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

    context 'when thread_id is missing' do
      let(:params) { {} }

      it 'raises MissingMessageIdError' do
        expect { service.call! }.to raise_error(Connections::Exceptions::MissingMessageIdError, 'thread_id is missing')
      end
    end

    context 'when the connection is invalid' do
      before do
        allow(connection).to receive(:email_sender?).and_return(false)
      end

      it 'raises WrongCategoryError' do
        expect { service.call! }.to raise_error(Connections::Exceptions::WrongCategoryError, "#{service.class.name} doesn't support #{connection.category}")
      end
    end
  end

  describe '#query' do
    it 'returns the correct query parameters' do
      expected_query = { '$filter': "conversationId eq '#{params[:thread_id]}'" }

      query_params = service.send(:query)

      expect(query_params).to eq(expected_query)
    end
  end
end
