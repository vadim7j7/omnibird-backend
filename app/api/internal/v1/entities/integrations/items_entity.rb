# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Integrations
        class ItemsEntity < Grape::Entity
          expose(
            :items,
            using: ItemEntity,
            documentation: { is_array: true, **ItemEntity.documentation }
          )
        end
      end
    end
  end
end
