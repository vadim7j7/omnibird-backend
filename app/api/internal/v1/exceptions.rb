# frozen_string_literal: true

module Internal
  module V1
    module Exceptions
      AccountAccessError = Class.new(StandardError)
      UnauthorizedError  = Class.new(StandardError)
    end
  end
end
