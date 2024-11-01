# frozen_string_literal: true

module Internal
  module V1
    module Entities
      class BaseWithIdEntity < Grape::Entity
        expose(:id, documentation: { type: :integer })
      end
    end
  end
end
