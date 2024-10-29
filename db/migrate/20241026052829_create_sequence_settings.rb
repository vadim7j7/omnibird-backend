class CreateSequenceSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :sequence_settings do |t|
      t.belongs_to :sequence, null: false, foreign_key: true, index: false
      t.belongs_to :connection, null: false, foreign_key: true

      t.string :timezone, default: nil
      t.date :schedule_start_at, default: nil
      t.time :allowed_send_window_from, default: nil
      t.time :allowed_send_window_to, default: nil
      t.time :skip_time_window_from, default: nil
      t.time :skip_time_window_to, default: nil

      t.boolean :exit_on_sender_email_received, null: false, default: false
      t.boolean :exit_on_meeting_booked, null: false, default: false
      t.boolean :exit_all_same_domain, null: false, default: false
      t.boolean :exit_on_domain_reply, null: false, default: false

      t.boolean :tracking_opens, null: false, default: true
      t.boolean :tracking_clicks, null: false, default: true

      t.boolean :prevent_repeat_send, null: false, default: false
      t.boolean :prevent_multi_sequence_send, null: false, default: false
      t.boolean :prevent_repeat_send_in_groups, null: false, default: false

      t.string :cc_email, null: false, array: true, default: []
      t.string :bcc_email, null: false, array: true, default: []

      t.timestamps
    end

    add_index :sequence_settings, :sequence_id, unique: true
  end
end
