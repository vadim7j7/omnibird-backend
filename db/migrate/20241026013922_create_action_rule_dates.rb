class CreateActionRuleDates < ActiveRecord::Migration[7.2]
  def change
    create_table :action_rule_dates do |t|
      t.belongs_to :action_rule, null: false, foreign_key: true
      t.string :name, null: false
      t.string :group_key, null: false

      t.integer :day
      t.integer :month
      t.integer :year

      t.integer :week_day
      t.integer :week_ordinal
      t.boolean :week_is_last_day

      t.timestamps
    end
  end
end
