# frozen_string_literal: true

module Tracking
  class ClickEmailLinkService < ApplicationService
    private

    def call!
      return if @params[:body].blank?

      nil
    end
  end
end
