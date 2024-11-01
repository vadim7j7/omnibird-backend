# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Integrations
        class ItemEntity < BaseWithIdEntity
          expose(:uuid,     documentation: { type: :string })
          expose(:category, documentation: { type: :string, values: ::Connection.categories.keys })
          expose(:provider, documentation: { type: :string, values: ::Connection.providers.keys })
          expose(:status,   documentation: { type: :string, values: ::Connection.statuses.keys })
          expose(
            :provider_source_data,
            as: :data,
            using: ConnectedDataEntity,
            documentation: ConnectedDataEntity.documentation
          )
        end
      end
    end
  end
end
