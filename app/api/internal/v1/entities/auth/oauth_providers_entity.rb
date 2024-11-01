# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Auth
        class OauthProvidersEntity < Grape::Entity
          expose(
            :items,
            using: OauthProviderEntity,
            documentation: { is_array: true, **OauthProviderEntity.documentation }
          )
        end
      end
    end
  end
end
