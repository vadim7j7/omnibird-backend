class CreateConnections < ActiveRecord::Migration[7.2]
  def change
    create_table :connections do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true

      t.string :uuid, null: true
      t.integer :category, null: false
      t.integer :provider, null: false
      t.integer :status, null: false, default: 0

      t.string :credentials, default: nil
      t.jsonb :metadata, default: {}
      t.jsonb :provider_source_data, default: {}
      t.jsonb :provider_errors, default: nil

      t.string :state_token, limit: 36, null: true, default: nil, index: true

      t.datetime :expired_at, index: true, default: nil

      t.timestamps
    end

    add_index :connections, %i[uuid category provider], unique: true
  end
end
