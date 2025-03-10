class CreateContactSequenceStages < ActiveRecord::Migration[7.2]
  def change
    create_table :contact_sequence_stages do |t|
      t.belongs_to :contact_sequence, null: false, foreign_key: true
      t.belongs_to :sequence_stage, null: false, foreign_key: true
      t.belongs_to :message_sent_session, null: true, foreign_key: true

      t.jsonb :stage_snapshot, default: {}

      t.timestamps
    end
  end
end
