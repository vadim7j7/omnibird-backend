class CreateConnections < ActiveRecord::Migration[7.2]
  def change
    create_table :connections do |t|
      t.string :uuid_service, null: true
      t.integer :category, null: false
      t.integer :service, null: false
      t.integer :status, null: false, default: 0

      t.jsonb :credentials, default: {}
      t.jsonb :metadata, default: {}
      t.jsonb :service_source_data, default: {}
      t.jsonb :service_errors, default: nil

      t.string :state_token, limit: 36, null: true, default: nil, index: true

      t.timestamps
    end

    add_index :connections, %i[uuid_service category service], unique: true
  end
end
