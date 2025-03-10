# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :connection do
    association :account
    association :user

    uuid { Faker::Internet.uuid }
    status { :connected }

    provider_source_data do
      { avatar: Faker::Avatar.image,
        email: Faker::Internet.email,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name }
    end

    factory :google_oauth do
      category { :oauth }
      provider { :google }
    end

    factory :google_email_sender do
      category { :email_sender }
      provider { :google }

      expired_at { Time.at(Faker::Omniauth.google[:credentials][:expires_at]) }

      credentials do
        data = Faker::Omniauth.google

        { token_type: 'Bearer',
          access_token: data[:credentials][:token],
          refresh_token: data[:credentials][:refresh_token] }.to_json
      end
    end

    factory :microsoft_oauth do
      category { :oauth }
      provider { :microsoft }
    end

    factory :microsoft_email_sender do
      category { :email_sender }
      provider { :microsoft }

      metadata do
        { 'oauth_params' => { 'redirect_uri' => Faker::Internet.url,
                              'scope' => 'openid profile email offline_access User.Read Mail.Read Mail.Send' } }
      end

      expired_at { Time.at(Faker::Omniauth.google[:credentials][:expires_at]) }

      credentials do
        data = Faker::Omniauth.google

        { token_type: 'Bearer',
          access_token: data[:credentials][:token],
          refresh_token: data[:credentials][:refresh_token] }.to_json
      end
    end

    factory :smtp_email_sender do
      category { :email_sender }
      provider { :smtp }
      
      credentials do
        { address: 'smtp.gmail.com',
          port: 587,
          domain: Faker::Internet.domain_name,
          username: Faker::Internet.email,
          password: Faker::Internet.password,
          authentication: :plain,
          enable_starttls_auto: true }.to_json
      end
    end
  end
end
