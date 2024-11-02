class CreateSequences < ActiveRecord::Migration[7.2]
  def change
    create_table :sequences do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true

      t.string :name
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
