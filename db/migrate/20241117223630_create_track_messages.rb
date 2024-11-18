class CreateTrackMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :track_messages do |t|
      t.belongs_to :message_sent_session, null: false, foreign_key: true

      t.string :tracking_key, null: false
      t.integer :action_type, null: false

      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :track_messages, :tracking_key, unique: true
  end
end
