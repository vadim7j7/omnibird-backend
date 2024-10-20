# frozen_string_literal: true

module Connections
  class Exceptions
    WrongProviderError       = Class.new(StandardError)
    WrongCategoryError       = Class.new(StandardError)
    InvalidRefreshTokenError = Class.new(StandardError)
    AccessTokenExpiredError  = Class.new(StandardError)
    MissingMessageIdError    = Class.new(StandardError)
  end
end
