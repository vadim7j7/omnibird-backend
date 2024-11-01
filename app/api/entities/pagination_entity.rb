# frozen_string_literal: true

module Entities
  class PaginationEntity < Grape::Entity
    expose(:page,     documentation: { type: :integer }, default: 1)
    expose(:per_page, documentation: { type: :integer }, default: 10)
    expose(:total,    documentation: { type: :integer }, default: 0)
  end
end
