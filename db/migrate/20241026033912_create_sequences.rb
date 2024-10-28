class CreateSequences < ActiveRecord::Migration[7.2]
  def change
    create_table :sequences do |t|
      t.string :name
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
