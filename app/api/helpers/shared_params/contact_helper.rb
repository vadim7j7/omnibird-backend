# frozen_string_literal: true

module Helpers
  module SharedParams
    module ContactHelper
      extend Grape::API::Helpers

      params(:contact_params) do
        requires(:contact, type: Hash) do
          requires(:email, type: String, desc: 'Email address')
          optional(:first_name, type: String, desc: 'First Name')
          optional(:last_name, type: String, desc: 'Last Name')
        end
      end
    end
  end
end
