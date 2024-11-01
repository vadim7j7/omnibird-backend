# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Auth
        class OauthProviderEntity < Grape::Entity
          expose(:provider, documentation: { type: :string, values: ::Connection.providers.keys })
          expose(:title,    documentation: { type: :string })
          expose(:icon,     documentation: { type: :string })
        end
      end
    end
  end
end
