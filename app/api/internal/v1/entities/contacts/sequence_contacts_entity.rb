# frozen_string_literal: true

module Internal
  module V1
    module Entities
      module Contacts
        class SequenceContactsEntity < Grape::Entity
          expose(
            :contacts,
            using: SequenceContactEntity,
            documentation: { is_array: true, **SequenceContactEntity.documentation }
          )
        end
      end
    end
  end
end
