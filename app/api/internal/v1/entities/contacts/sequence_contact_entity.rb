# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Contacts
        class SequenceContactEntity < BaseWithIdEntity
          expose(
            :contact,
            using: ItemEntity,
            documentation: { **ItemEntity.documentation }
          )

          expose(:status, documentation: { type: :string, values: ::ContactSequence.statuses.keys })
          expose(:variables, documentation: { type: Hash })

          expose(:scheduled_at, documentation: { type: DateTime })
          expose(:archived_at, documentation: { type: DateTime })
        end
      end
    end
  end
end
