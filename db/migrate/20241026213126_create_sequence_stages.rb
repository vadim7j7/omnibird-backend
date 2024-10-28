class CreateSequenceStages < ActiveRecord::Migration[7.2]
  def change
    create_table :sequence_stages do |t|
      t.belongs_to :sequence, null: false, foreign_key: true

      t.integer :stage_index, null: false, default: 0

      t.string :subject, default: nil
      t.text :template, limit: 16_000
      t.text :variables, array: true, default: []

      t.integer :perform_in_amount, default: nil
      t.integer :perform_in_period, default: nil
      t.integer :perform_reason, default: nil

      t.time :allowed_send_window_from, default: nil
      t.time :allowed_send_window_to, default: nil

      t.boolean :send_in_thread, null: false, default: true

      t.timestamps
    end

    add_index :sequence_stages, %i[sequence_id stage_index]
  end
end
