# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Sequences
        class ItemsEntity < Grape::Entity
          expose(
            :items,
            using: ItemPreviewEntity,
            documentation: { is_array: true, **ItemPreviewEntity.documentation }
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
