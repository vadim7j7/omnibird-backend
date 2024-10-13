# frozen_string_literal: true

module Connections
  class Exceptions
    WrongProviderError       = Class.new(StandardError)
    InvalidRefreshTokenError = Class.new(StandardError)
  end
end
