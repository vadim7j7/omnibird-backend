# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Contacts
        class ItemEntity < BaseWithIdEntity
          expose(:email,        documentation: { type: :string })
          expose(:first_name,   documentation: { type: :string })
          expose(:last_name,    documentation: { type: :string })
          expose(:email_domain, documentation: { type: :string })
        end
      end
    end
  end
end
