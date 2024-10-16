# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Google::SendEmailService, type: :service) do
  let(:send_messages_url) { 'https://gmail.googleapis.com/gmail/v1/users/me/messages/send' }

  let(:connection) { create(:google_email_sender) }
  let(:params) { { encoded_message: Base64.encode64(Faker::HTML.paragraph) } }
  let(:service) { described_class.new(connection:, params:) }
  let(:authorization) { "#{connection.credentials_parsed[:token_type]} #{connection.credentials_parsed[:access_token]}" }

  describe '#call!' do
    context 'when connection is valid and email is sent successfully' do
      let(:success_response) do
        { 'id' => Faker::Internet.uuid,
          'threadId' => Faker::Internet.uuid,
          'labelIds' => [Faker::Internet.uuid] }
      end

      before do
        allow(HTTParty).to receive(:post).and_return(double(success?: true, parsed_response: success_response))
      end

      it 'sends an email through the Google API' do
        service.call!

        expect(HTTParty).to have_received(:post).with(
          send_messages_url,
          body: { raw: params[:encoded_message] }.to_json,
          headers: { Authorization: authorization, 'Content-Type': 'application/json' }
        )
      end

      it 'sets result with the response' do
        service.call!
        expect(service.result[:api_message][:id]).to be_present
        expect(service.result[:api_message]).to eq(success_response.deep_symbolize_keys)
      end

      it 'does not set any error' do
        service.call!
        expect(service.result[:error]).to be_nil
      end
    end

    context 'when the email sending fails' do
      let(:failed_response) do
        { 'error' => {
            'code' => 401,
            'message' => '....',
            'errors' => [{'message': '...'}]
          } }
      end

      before do
        allow(HTTParty).to receive(:post).and_return(double(success?: false, parsed_response: failed_response))
      end

      it 'sets result[:error] with the error message' do
        service.call!
        expect(service.result[:error]).to eq(failed_response['error'].deep_symbolize_keys)
      end

      it 'sets status to false' do
        service.call!
        expect(service.status).to be_falsey
      end
    end

    describe '#headers' do
      it 'generates the correct authorization headers' do
        expect(service.send(:headers))
          .to eq({ Authorization: authorization, 'Content-Type': 'application/json' })
      end
    end

    describe '#body' do
      it 'generates the correct body for the request' do
        expect(service.send(:body)).to eq({ raw: params[:encoded_message] }.to_json)
      end
    end
  end
end
