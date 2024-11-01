# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Sequences
        class ItemEntity < BaseWithIdEntity
          expose(:name, documentation: { type: :string })
          expose(
            :status,
            documentation: {
              type: :string,
              values: ::Sequence.statuses.keys
            }
          )
        end
      end
    end
  end
end
