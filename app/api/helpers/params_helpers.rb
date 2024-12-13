# frozen_string_literal: true

module Helpers
  module ParamsHelpers
    extend Grape::API::Helpers

    # @return[Hash]
    def declared_params(options = {})
      @declared_params ||=
        declared(params, evaluate_given: true, include_missing: false, **options)
    end
  end
end
