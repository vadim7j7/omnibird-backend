class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.string :email, null: false
      t.string :first_name
      t.string :last_name

      t.string :email_domain, index: true

      t.timestamps
    end

    add_index :contacts, :email, unique: true
  end
end
