# frozen_string_literal: true

module Tracking
  class OpenEmailUrlService < ApplicationService
    private

    def call!
      return if @params[:body].blank?

      track_message.save!
      adding_tracking_url!

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

    def adding_tracking_url!
      doc = Nokogiri::HTML5(@params[:body])
      doc.at('body').children.before(img_tag(doc:))

      @result[:updated_body] = doc.at('body').children.to_html

      nil
    end

    # @param[Nokogiri::HTML5::Document] doc
    # @return[Nokogiri::XML::Node]
    def img_tag(doc:)
      img_tag = Nokogiri::XML::Node.new('img', doc)
      img_tag['alt']    = ''
      img_tag['width']  = '1'
      img_tag['height'] = '1'
      img_tag['style']  = css_style
      img_tag['src']    = tracking_url(track_message.tracking_key)

      img_tag
    end

    # @return[String]
    def css_style
      'height:1px !important; width:1px !important; border: 0 !important; margin: 0 !important; padding: 0 !important'
    end
  end
end
