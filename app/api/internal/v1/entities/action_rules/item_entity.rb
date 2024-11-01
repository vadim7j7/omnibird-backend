# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module ActionRules
        class ItemEntity < BaseWithIdEntity
          expose(:name,          documentation: { type: :string })
          expose(:group_key,     documentation: { type: :string })
          expose(:action_type,   documentation: { type: :string, values: ActionRule.action_types.keys })
          expose(:system_action, documentation: { type: :boolean })

          expose(
            :dates_map,
            using: DateMapEntity,
            documentation: { is_array: true, **DateMapEntity.documentation }
          )
        end
      end
    end
  end
end
