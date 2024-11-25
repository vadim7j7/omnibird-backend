# frozen_string_literal: true

module Tracking
  class ClickEmailLinkService < ApplicationService
    private

    def call!
      return if @params[:body].blank?

      adding_tracking_url!

      @result[:updated_body] = document.at('body').children.to_html

      nil
    end

    # @return[Nokogiri::HTML5::Document]
    def document
      @document ||= Nokogiri::HTML5(@params[:body])
    end

    def adding_tracking_url!
      document
        .xpath('//a[@href]')
        .each { |element| replace_link!(element:) }

      nil
    end

    # @param[<Nokogiri::XML::Element] element
    def replace_link!(element:)
      record = TrackMessage.new(action_type: :click_link, message_sent_session: @params[:message_sent_session])
      record.metadata['original_url'] = element['href']
      record.created_at = Time.zone.now
      record.updated_at = Time.zone.now
      record.save!

      element['href'] = record.url

      nil
    end
  end
end
