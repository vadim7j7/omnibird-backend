class CreateActionRules < ActiveRecord::Migration[7.2]
  def change
    create_table :action_rules do |t|
      t.string :name, null: false
      t.string :group_key, null: false, index: true
      t.integer :action_type, null: false

      t.boolean :system_action, null: false, default: false

      t.timestamps
    end
  end
end
