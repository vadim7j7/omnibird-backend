# frozen_string_literal: true

module Sequences
  class Base < ApplicationService
    attr_reader :result, :status, :sequence

    # @param[User] user
    # @param[Account] account
    # @param[Hash] params
    # @param[Sequence] sequence
    def initialize(user:, account:, params: {}, sequence: nil)
      super(params:)

      @user     = user
      @account  = account
      @sequence = sequence
    end

    # @return[User]
    def current_user
      @user
    end

    # @return[Account]
    def current_account
      @account
    end
  end
end
