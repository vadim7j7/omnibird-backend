# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Contacts
        class ItemsEntity < Grape::Entity
          expose(
            :items,
            using: ItemEntity,
            documentation: { is_array: true, **ItemEntity.documentation }
          )

          expose(:meta) do
            expose(
              :pagination,
              using: ::Entities::PaginationEntity,
              documentation: ::Entities::PaginationEntity.documentation
            )
          end
        end
      end
    end
  end
end
