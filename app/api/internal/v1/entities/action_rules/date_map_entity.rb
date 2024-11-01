# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module ActionRules
        class DateMapEntity < BaseWithIdEntity
          expose(:name,      documentation: { type: :string })
          expose(:group_key, documentation: { type: :string })

          expose(:day,   documentation: { type: :integer })
          expose(:month, documentation: { type: :integer })
          expose(:year,  documentation: { type: :integer })

          expose(:week_day,         documentation: { type: :integer })
          expose(:week_ordinal,     documentation: { type: :integer })
          expose(:week_is_last_day, documentation: { type: :boolean })
        end
      end
    end
  end
end
