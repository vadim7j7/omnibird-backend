class CreateContactSequenceStageActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :contact_sequence_stage_activities do |t|
      t.belongs_to :contact_sequence_stage, null: false, foreign_key: true

      t.integer :event_type, null: false
      t.jsonb :event_metadata, null: false, default: {}

      t.timestamps
    end
  end
end
