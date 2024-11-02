class CreateAccountUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :account_users do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :role, default: 1, null: false

      t.timestamps
    end
  end
end
