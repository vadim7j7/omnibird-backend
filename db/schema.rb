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
    t.string "uuid_service"
    t.integer "category", null: false
    t.integer "service", null: false
    t.integer "status", default: 0, null: false
    t.jsonb "credentials", default: {}
    t.jsonb "metadata", default: {}
    t.jsonb "service_source_data", default: {}
    t.jsonb "service_errors"
    t.string "stage_token", limit: 36
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stage_token"], name: "index_connections_on_stage_token"
    t.index ["uuid_service", "category", "service"], name: "index_connections_on_uuid_service_and_category_and_service", unique: true
  end
end
