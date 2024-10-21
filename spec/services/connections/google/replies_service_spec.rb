# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Google::RepliesService, type: :service) do
  let(:connection) { create(:google_email_sender) }
  let(:params) { { thread_id: Faker::Internet.uuid } }
  let(:service) { described_class.new(connection:, params:) }
  let(:authorization) { "#{connection.credentials_parsed[:token_type]} #{connection.credentials_parsed[:access_token]}" }

  describe '#call!' do
    context 'when thread_id is provided' do
      let(:api_response) do
        {
          messages: [
            {
              id: Faker::Alphanumeric.alphanumeric(number: 10),
              payload: {
                headers: [
                  { name: 'In-Reply-To', value: Faker::Internet.email },
                  { name: 'Subject', value: "Re: #{Faker::Lorem.sentence(word_count: 3)}" }
                ]
              }
            },
            {
              id: Faker::Alphanumeric.alphanumeric(number: 10),
              payload: {
                headers: [
                  { name: 'Subject', value: Faker::Lorem.sentence(word_count: 3) }
                ]
              }
            }
          ]
        }
      end

      before do
        allow(HTTParty).to receive(:get).and_return(double(success?: true, parsed_response: api_response))
      end

      it 'returns replies that have In-Reply-To headers' do
        service.call!

        expect(service.result[:source_data].size).to eq(1)
        expect(service.result[:source_data].first[:payload][:headers].any? { |r| r[:name] == 'In-Reply-To' }).to be true
        expect(service.status).to be true
      end
    end

    context 'when the API returns an error response' do
      let(:error_response) do
        {
          error: {
            code: 'InvalidRequest',
            message: 'Invalid threadId',
            errors: [{ reason: 'invalidArgument', message: 'Invalid threadId' }]
          }
        }
      end

      before do
        allow(HTTParty).to receive(:get).and_return(double(success?: false, parsed_response: error_response))
      end

      it 'handles the error response correctly' do
        service.call!

        expect(service.result[:error][:message]).to eq('Invalid threadId')
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

  describe '#find_replies!' do
    it 'filters messages with In-Reply-To headers' do
      messages = [
        {
          payload: {
            headers: [{ name: 'In-Reply-To', value: 'some_message_id' }]
          }
        },
        {
          payload: {
            headers: [{ name: 'Subject', value: 'Normal subject' }]
          }
        }
      ]

      service.send(:find_replies!, items: messages)
      expect(service.result[:source_data].size).to eq(1)
      expect(service.result[:source_data].first[:payload][:headers].any? { |r| r[:name] == 'In-Reply-To' }).to be true
    end
  end
end
