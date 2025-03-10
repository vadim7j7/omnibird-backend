# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength:
namespace :google_sandbox do
  desc 'Get oAuth sending email url for google'
  task oauth_url: :environment do
    connection = Connection.find_or_create_by!(category: :email_sender, provider: :google)
    service = Connections::Google::OauthUrlService.new(connection:)
    service.call!

    puts service.result[:oauth_url].inspect
  end

  desc 'Get credentials by code and state from google'
  task code_to_token: :environment do
    code  = ENV.fetch('CODE')
    state = ENV.fetch('STATE')

    connection = Connection.find_by!(state_token: state)
    service    = Connections::Google::CredentialsService.new(connection:, params: { code: })
    service.call!

    puts service.credentials.inspect
  end

  desc 'Send email via gmail'
  task send_email: :environment do
    email_to    = ENV.fetch('TO')
    subject     = ENV.fetch('SUBJECT', 'Testing')
    attachment  = ENV['FILE_URL']
    in_reply_to = ENV['IN_REPLY_TO']
    thread_id   = ENV['THREAD_ID']

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

    connection = Connection.connected.find_by!(category: :email_sender, provider: :google)
    if connection.expired?
      service = Connections::Google::RefreshCredentialsService.new(connection:)
      service.call!
      connection = connection.reload
    end

    service = Connections::Google::SendEmailService.new(
      connection:,
      params: { thread_id:, encoded_message: mailer_service.as_string }
    )
    service.call!

    puts service.result
  end

  desc 'Get details of an email by ID'
  task email_details: :environment do
    message_id = ENV.fetch('MESSAGE_ID')

    connection = Connection.connected.find_by!(category: :email_sender, provider: :google)
    if connection.expired?
      service = Connections::Google::RefreshCredentialsService.new(connection:)
      service.call!
      connection = connection.reload
    end

    service = Connections::Google::EmailDetailsService.new(
      connection:,
      params: { message_id: }
    )
    service.call!

    puts JSON.pretty_generate(service.result)
  end
end
# rubocop:enable Metrics/BlockLength:
