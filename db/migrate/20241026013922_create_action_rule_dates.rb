class CreateActionRuleDates < ActiveRecord::Migration[7.2]
  def change
    create_table :action_rule_dates do |t|
      t.belongs_to :action_rule, null: false, foreign_key: true
      t.integer :day, index: true
      t.integer :month, index: true
      t.integer :year, index: true
      t.integer :day_of_week, index: true

      t.timestamps
    end
  end
end
