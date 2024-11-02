class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true

      t.string :email, null: false
      t.string :first_name
      t.string :last_name

      t.string :email_domain, index: true

      t.timestamps
    end

    add_index :contacts, :email, unique: true
  end
end
