# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_10_13_054809) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "connections", force: :cascade do |t|
    t.string "uuid"
    t.integer "category", null: false
    t.integer "provider", null: false
    t.integer "status", default: 0, null: false
    t.string "credentials"
    t.jsonb "metadata", default: {}
    t.jsonb "provider_source_data", default: {}
    t.jsonb "provider_errors"
    t.string "state_token", limit: 36
    t.datetime "expired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expired_at"], name: "index_connections_on_expired_at"
    t.index ["state_token"], name: "index_connections_on_state_token"
    t.index ["uuid", "category", "provider"], name: "index_connections_on_uuid_and_category_and_provider", unique: true
  end
end
