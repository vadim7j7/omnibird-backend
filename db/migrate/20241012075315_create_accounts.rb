class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :domain

      t.integer :type_of_account, default: 0

      t.timestamps
    end

    add_index :accounts, :slug, unique: true
    add_index :accounts,
              :domain,
              unique: true,
              where: 'domain IS NOT NULL',
              name: 'index_accounts_on_domain_unique_with_nil'
  end
end
