# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Connections::Google::OauthUrlService, type: :service) do
  describe 'Sign in/up oAuth url' do
    let!(:connection) { build(:google_oauth) }

    subject { Connections::Google::OauthUrlService.new(connection:) }
    before { subject.call! }

    context 'URI Query' do
      let!(:url_params) { Rack::Utils.parse_query(URI.parse(subject.result[:oauth_url]).query).deep_symbolize_keys }

      it { expect(url_params[:response_type]).to eq('code') }
      it { expect(url_params[:client_id]).to eq(ENV.fetch('SERVICE_GOOGLE_CLIENT_ID')) }
      it { expect(url_params[:redirect_uri]).to include('auth/callback/google') }
      it { expect(url_params[:scope]).to eq('https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile') }
      it { expect(url_params[:state]).to be_present }
      it { expect(subject.connection.persisted?).to be_truthy }
    end
  end

  describe 'Integration send email oAuth url' do
    let!(:connection) { build(:google_email_sender) }

    subject { Connections::Google::OauthUrlService.new(connection:) }
    before { subject.call! }

    let!(:url_params) { Rack::Utils.parse_query(URI.parse(subject.result[:oauth_url]).query).deep_symbolize_keys }

    it { expect(url_params[:access_type]).to eq('offline') }
    it { expect(url_params[:prompt]).to eq('consent') }
    it { expect(url_params[:response_type]).to eq('code') }
    it { expect(url_params[:client_id]).to eq(ENV.fetch('SERVICE_GOOGLE_CLIENT_ID')) }
    it { expect(url_params[:redirect_uri]).to include('auth/callback/google') }
    it { expect(url_params[:scope]).to eq('https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/gmail.compose https://www.googleapis.com/auth/gmail.readonly') }
    it { expect(url_params[:state]).to be_present }
    it { expect(subject.connection.persisted?).to be_truthy }
  end
end
