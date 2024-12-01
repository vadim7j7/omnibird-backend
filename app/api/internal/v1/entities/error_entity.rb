# frozen_string_literal: true

module Internal
  module V1
    module Entities
      class ErrorEntity < Grape::Entity
        expose(:message, documentation: { type: :string })
        expose(:errors,  documentation: { type: :object }, default: {})
        expose(:reason,  documentation: { type: :string })
        expose(:meta,    documentation: { type: :object })
      end
    end
  end
end
