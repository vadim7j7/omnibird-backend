class CreateContactSequences < ActiveRecord::Migration[7.2]
  def change
    create_table :contact_sequences do |t|
      t.belongs_to :contact, null: false, foreign_key: true
      t.belongs_to :sequence, null: false, foreign_key: true
      t.belongs_to :connection, null: false, foreign_key: true

      t.integer :status, null: false, default: 0

      t.jsonb :variables, default: {}

      t.datetime :scheduled_at, default: nil
      t.datetime :archived_at, default: nil

      t.timestamps
    end
  end
end
