# frozen_string_literal: true

module Helpers
  module SharedParams
    module Main
      extend Grape::API::Helpers

      params(:pagination) do
        optional(:pagination, type: Hash) do
          optional(:page, type: Integer, default: 1, values: 1..)
          optional(:per_page, type: Integer, default: 10, values: 5..100)
        end
      end
    end
  end
end
