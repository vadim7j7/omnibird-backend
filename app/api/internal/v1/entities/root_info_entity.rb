# frozen_string_literal: true

module Internal
  module V1
    module Entities
      class RootInfoEntity < Grape::Entity
        expose(:name,    documentation: { type: :string })
        expose(:version, documentation: { type: :string })
      end
    end
  end
end
