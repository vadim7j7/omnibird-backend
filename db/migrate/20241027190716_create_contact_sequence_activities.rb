class CreateContactSequenceActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :contact_sequence_activities do |t|
      t.belongs_to :contact_sequence, null: false, foreign_key: true

      t.integer :event_type, null: false
      t.jsonb :event_metadata, null: false, default: {}

      t.timestamps
    end
  end
end
