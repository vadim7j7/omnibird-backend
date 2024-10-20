# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Microsoft::OauthUrlService, type: :service) do
  describe 'Sign in/up oAuth url' do
    let!(:connection) { build(:microsoft_oauth) }

    subject { described_class.new(connection:) }
    before { subject.call! }

    context 'URI Query' do
      let!(:url_params) { Rack::Utils.parse_query(URI.parse(subject.result[:oauth_url]).query).deep_symbolize_keys }

      it { expect(url_params[:response_type]).to eq('code') }
      it { expect(url_params[:client_id]).to eq(ENV.fetch('SERVICE_MICROSOFT_CLIENT_ID')) }
      it { expect(url_params[:redirect_uri]).to include('auth/callback/microsoft') }
      it { expect(url_params[:scope]).to eq('openid profile email User.Read') }
      it { expect(url_params[:state]).to be_present }
      it { expect(subject.connection.persisted?).to be_truthy }
    end
  end

  describe 'Integration send email oAuth url' do
    let!(:connection) { build(:microsoft_email_sender) }

    subject { described_class.new(connection:) }
    before { subject.call! }

    let!(:url_params) { Rack::Utils.parse_query(URI.parse(subject.result[:oauth_url]).query).deep_symbolize_keys }

    it { expect(url_params[:response_type]).to eq('code') }
    it { expect(url_params[:client_id]).to eq(ENV.fetch('SERVICE_MICROSOFT_CLIENT_ID')) }
    it { expect(url_params[:redirect_uri]).to include('auth/callback/microsoft') }
    it { expect(url_params[:scope]).to eq('openid profile email offline_access User.Read Mail.Read Mail.Send') }
    it { expect(url_params[:state]).to be_present }
    it { expect(subject.connection.persisted?).to be_truthy }
  end

  describe 'validate provider' do
    let!(:connection) { build(:connection, category: :oauth, provider: :google) }

    subject { described_class.new(connection:) }

    it { expect { subject.call! }.to raise_error(Connections::Exceptions::WrongProviderError) }
  end
end
