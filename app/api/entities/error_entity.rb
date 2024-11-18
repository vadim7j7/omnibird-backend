# frozen_string_literal: true

module Entities
  class ErrorEntity < Grape::Entity
    expose(:message, documentation: { type: :string })
    expose(:errors,  documentation: { type: :object, is_array: true }, default: [])
    expose(:reason,  documentation: { type: :string })
    expose(:meta,    documentation: { type: :object })
  end
end
