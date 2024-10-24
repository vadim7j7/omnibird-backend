# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :message_sent_session do
    message_id { Faker::Internet.uuid }
    thread_id { Faker::Internet.uuid }
    mail_id { Faker::Internet.uuid }

    stage { :retrieve }
    status { :completed }
  end
end
