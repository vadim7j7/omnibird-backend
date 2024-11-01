# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Integrations
        class AuthUrlEntity < Grape::Entity
          expose(:url, documentation: { type: :string })
        end
      end
    end
  end
end
