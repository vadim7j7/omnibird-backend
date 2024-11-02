class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :first_name
      t.string :last_name

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
