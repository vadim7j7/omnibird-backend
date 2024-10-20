# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
namespace :microsoft_sandbox do
  desc 'Get oAuth sending email url for microsoft'
  task oauth_url: :environment do
    connection = Connection.find_or_create_by!(category: :email_sender, provider: :microsoft)
    service = Connections::Microsoft::OauthUrlService.new(connection:)
    service.call!

    puts service.result[:oauth_url].inspect
  end

  desc 'Get credentials by code and state from microsoft'
  task code_to_token: :environment do
    code  = ENV.fetch('CODE')
    state = ENV.fetch('STATE')

    connection = Connection.find_by!(state_token: state)
    service    = Connections::Microsoft::CredentialsService.new(connection:, params: { code: })
    service.call!

    puts service.credentials.inspect
  end

  desc 'Send email via microsoft (outlook)'
  task send_email: :environment do
    email_to    = ENV.fetch('TO')
    subject     = ENV.fetch('SUBJECT', 'Testing')
    attachment  = ENV['FILE_URL']
    in_reply_to = ENV['IN_REPLY_TO']

    mailer_service = Message::MailerService.new(
      params: {
        subject:,
        in_reply_to:,
        to: [ email_to ],
        body: '<strong>Hello</strong>',
        attachments: attachment && [ attachment ]
      }
    )
    mailer_service.call

    connection = Connection.connected.find_by!(category: :email_sender, provider: :microsoft)
    if connection.expired?
      service = Connections::Microsoft::RefreshCredentialsService.new(connection:)
      service.call!
      connection = connection.reload
    end

    service = Connections::Microsoft::SendEmailService.new(
      connection:,
      params: { mailer_service: }
    )
    service.call!

    puts service.result
  end

  desc 'Get latest email details by subject and email to'
  task latest_email: :environment do
    email_to = ENV.fetch('EMAIL_TO')
    subject  = ENV.fetch('SUBJECT')

    connection = Connection.connected.find_by!(category: :email_sender, provider: :microsoft)
    if connection.expired?
      service = Connections::Microsoft::RefreshCredentialsService.new(connection:)
      service.call!
      connection = connection.reload
    end

    service = Connections::Microsoft::EmailDetailsService.new(connection:, params: { subject:, to: email_to })
    service.call!

    puts JSON.pretty_generate(service.result)
  end
end
# rubocop:enable Metrics/BlockLength:
