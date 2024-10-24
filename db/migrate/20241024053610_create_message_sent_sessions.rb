class CreateMessageSentSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :message_sent_sessions do |t|
      t.belongs_to :connection, null: false, foreign_key: true

      t.string :message_id
      t.string :thread_id
      t.string :mail_id

      t.integer :stage, default: 0, null: false
      t.integer :status, default: 0, null: false

      t.jsonb :data_source_response, default: {}
      t.jsonb :data_source_message_details, default: {}

      t.string :raw_message

      t.timestamps
    end
  end
end
