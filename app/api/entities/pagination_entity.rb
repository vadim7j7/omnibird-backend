# frozen_string_literal: true

module Entities
  class PaginationEntity < Grape::Entity
    expose(:page, default: 1, documentation: { type: :integer })
    expose(:per_page, default: 10, documentation: { type: :integer })
    expose(:total, default: 0, documentation: { type: :integer })
  end
end
