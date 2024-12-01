# frozen_string_literal: true

module Helpers
  module SharedParams
    module SequenceHelper
      extend Grape::API::Helpers

      params(:sequence_setting_params) do
        optional(:id, type: Integer, desc: 'ID of the sequence settings to update record')

        requires(:connection_id, type: Integer, desc: 'Connection ID')

        optional(:timezone, type: String, default: Time.zone.tzinfo.name, desc: 'Timezone fot the sequence')
        optional(:schedule_start_at, type: DateTime, desc: 'When to start the sequence')
        optional(:allowed_send_window_from, type: Time, desc: 'Time range when to allow to send the sequence FROM')
        optional(:allowed_send_window_to, type: Time, desc: 'Time range when to allow to send the sequence TO')
        optional(:skip_time_window_from, type: Time, desc: 'Time range when to skip sending the sequence FROM')
        optional(:skip_time_window_to, type: Time, desc: 'Time range when to skip sending the sequence TO')

        optional(
          :exit_on_sender_email_received,
          type: Boolean,
          default: false,
          desc: 'Stop sending when an email received'
        )
        optional(
          :exit_all_same_domain,
          type: Boolean,
          default: false,
          desc: 'Stop for all company emails with the same domain'
        )
        optional(
          :exit_on_domain_reply,
          type: Boolean,
          default: false,
          desc: 'Stop sending when a receiver replies'
        )

        optional(
          :tracking_opens,
          type: Boolean,
          default: true,
          desc: 'Tracking the status when an email is opened by a recipient'
        )
        optional(
          :tracking_clicks,
          type: Boolean,
          default: true,
          desc: 'Tracking the status when a link is clicked by a recipient'
        )

        optional(
          :prevent_multi_sequence_send,
          type: Boolean,
          default: true,
          desc: "Don't allow to add the same email in multiple sequences"
        )
        optional(
          :prevent_repeat_send_in_groups,
          type: Boolean,
          default: false,
          desc: "Don't allow to add the same email in some groups sequences"
        )

        optional(:cc_email, type: Array[String], default: [])
        optional(:bcc_email, type: Array[String], default: [])
      end

      params(:sequence_stage_params) do
        optional(:id, type: Integer, desc: 'ID of the stage to update the record')
        optional(:_destroy, type: Boolean, default: false, desc: 'Mark it to delete if id is provided')

        optional(:stage_index, type: Integer, default: 0, desc: 'Organizing the stage for a sequence')
        requires(:subject, type: String, desc: 'Subject for email')

        requires(:template, type: String, desc: 'Template message body')

        requires(:perform_in_unit, type: Integer, desc: 'Perform the stage after adding (in units)')
        requires(
          :perform_in_period,
          type: String,
          values: SequenceStage.perform_in_periods.keys,
          desc: 'Type of units when to perform the stage'
        )

        optional(:allowed_send_window_from, type: Time, desc: 'Time range when to allow to send the sequence FROM')
        optional(:allowed_send_window_to, type: Time, desc: 'Time range when to allow to send the sequence TO')
        optional(:timezone, type: String, default: Time.zone.tzinfo.name, desc: 'Timezone fot the state')

        optional(:send_in_thread, type: Boolean, default: true, desc: 'Send in the same thread of the first email')
      end

      params(:sequence_params) do
        requires(:name, type: String, desc: 'Name of a sequence')
      end

      params(:sequence_create_params) do
        requires(:sequence, type: Hash) do
          use(:sequence_params)

          requires(:sequence_setting_attributes, type: Hash) { use(:sequence_setting_params) }
          requires(:sequence_stages_attributes, type: Array) { use(:sequence_stage_params) }
        end
      end
    end
  end
end
