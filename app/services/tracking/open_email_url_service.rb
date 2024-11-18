# frozen_string_literal: true

module Tracking
  class OpenEmailUrlService < ApplicationService
    private

    def call!
      return if @params[:body].blank?

      track_message.save!

      nil
    end

    # @param[TrackMessage]
    def track_message
      @track_message ||=
        TrackMessage
        .new(action_type: :open_message, message_sent_session: @params[:message_sent_session])
    end

    # @param[String] tracking_key
    # @return[String]
    def tracking_url(tracking_key)
      "#{ENV.fetch('API_FULL_URI')}/v1/public/#{tracking_key}/1x1.png"
    end
  end
end
