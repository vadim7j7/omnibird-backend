class CreateActionRuleAssociations < ActiveRecord::Migration[7.2]
  def change
    create_table :action_rule_associations do |t|
      t.belongs_to :action_rule, null: false, foreign_key: true
      t.references :action_rule_association_able, polymorphic: true, null: false

      t.timestamps
    end
  end
end
