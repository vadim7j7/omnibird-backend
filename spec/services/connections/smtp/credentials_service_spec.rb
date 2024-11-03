# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Smtp::CredentialsService, type: :service) do
  let(:connection) { create(:smtp_email_sender) }
  let(:valid_params) do
    { address: 'smtp.gmail.com',
      port: 587,
      domain: 'example.com',
      username: 'user@example.com',
      password: 'password123',
      authentication: :plain,
      enable_starttls_auto: true }
  end

  subject { described_class.new(connection:, params: valid_params) }

  describe '#call!' do
    context 'with valid parameters' do
      let(:smtp_double) { instance_double(Net::SMTP) }

      before do
        allow(Net::SMTP).to receive(:new).and_return(smtp_double)
        allow(smtp_double).to receive(:enable_starttls_auto)
        allow(smtp_double).to receive(:start)
        allow(smtp_double).to receive(:finish)
      end

      it 'saves the SMTP credentials' do
        subject.call!

        expect(connection.reload).to be_connected
        expect(connection.credentials_parsed).to include(
          address: valid_params[:address],
          port: valid_params[:port],
          username: valid_params[:username]
        )
      end

      it 'tests the SMTP connection' do
        subject.call!

        expect(smtp_double).to have_received(:enable_starttls_auto)
        expect(smtp_double).to have_received(:start)
        expect(smtp_double).to have_received(:finish)
      end
    end

    context 'with missing required parameters' do
      let(:invalid_params) { { address: 'smtp.gmail.com' } }
      subject { described_class.new(connection:, params: invalid_params) }

      it 'collects all missing parameter errors' do
        expect { subject.call! }.to(
          raise_error(
            Connections::Exceptions::MissingParamError,
            /Missing required parameters: port, username, password, authentication/
          )
        )

        expect(subject.connection.provider_errors).to(
          eq('port' => 'port is required',
             'username' => 'username is required',
             'password' => 'password is required',
             'authentication' => 'authentication is required')
        )
      end
    end

    context 'when SMTP authentication fails' do
      before do
        allow_any_instance_of(Net::SMTP).to receive(:start)
          .and_raise(Net::SMTPAuthenticationError.new('Invalid credentials'))
      end

      it 'handles authentication errors' do
        expect { subject.call! }.to raise_error(Net::SMTPAuthenticationError)
        expect(connection.reload).not_to be_connected
      end
    end

    context 'when SMTP connection fails' do
      before do
        allow_any_instance_of(Net::SMTP).to receive(:start)
          .and_raise(StandardError.new('Connection refused'))
      end

      it 'handles connection errors' do
        expect { subject.call! }.to raise_error(StandardError)
        expect(connection.reload).not_to be_connected
      end
    end
  end
end
