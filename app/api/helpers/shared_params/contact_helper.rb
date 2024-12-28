# frozen_string_literal: true

module Helpers
  module SharedParams
    module ContactHelper
      extend Grape::API::Helpers

      params(:contact) do
        requires(:email, type: String, desc: 'Email address')
        optional(:first_name, type: String, desc: 'First Name')
        optional(:last_name, type: String, desc: 'Last Name')
      end

      params(:contact_params) do
        requires(:contact, type: Hash) do
          use(:contact)
        end
      end

      params(:contact_sequence_params) do
        requires(:contact_sequence, type: Hash) do
          optional(:contact_attributes, type: Hash) do
            use(:contact)
          end

          optional(:contact_id, type: Integer, desc: 'Contact ID if contact is missing')
          optional(:scheduled_at, type: DateTime, desc: 'Schedule Date when to start sending')
        end
      end
    end
  end
end
