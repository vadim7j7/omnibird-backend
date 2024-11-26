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

ActiveRecord::Schema[7.2].define(version: 2024_11_17_223630) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_users_on_account_id"
    t.index ["user_id"], name: "index_account_users_on_user_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "domain"
    t.integer "type_of_account", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain"], name: "index_accounts_on_domain_unique_with_nil", unique: true, where: "(domain IS NOT NULL)"
    t.index ["slug"], name: "index_accounts_on_slug", unique: true
  end

  create_table "action_rule_associations", force: :cascade do |t|
    t.bigint "action_rule_id", null: false
    t.string "action_rule_association_able_type", null: false
    t.bigint "action_rule_association_able_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_rule_association_able_type", "action_rule_association_able_id"], name: "index_action_rule_associations_on_action_rule_association_able"
    t.index ["action_rule_id"], name: "index_action_rule_associations_on_action_rule_id"
  end

  create_table "action_rule_dates", force: :cascade do |t|
    t.bigint "action_rule_id", null: false
    t.string "name", null: false
    t.string "group_key", null: false
    t.integer "day"
    t.integer "month"
    t.integer "year"
    t.integer "week_day"
    t.integer "week_ordinal"
    t.boolean "week_is_last_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_rule_id"], name: "index_action_rule_dates_on_action_rule_id"
  end

  create_table "action_rules", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "user_id"
    t.string "name", null: false
    t.string "group_key", null: false
    t.integer "action_type", null: false
    t.boolean "system_action", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_action_rules_on_account_id"
    t.index ["group_key"], name: "index_action_rules_on_group_key"
    t.index ["user_id"], name: "index_action_rules_on_user_id"
  end

  create_table "connections", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
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
    t.index ["account_id"], name: "index_connections_on_account_id"
    t.index ["expired_at"], name: "index_connections_on_expired_at"
    t.index ["state_token"], name: "index_connections_on_state_token"
    t.index ["user_id"], name: "index_connections_on_user_id"
    t.index ["uuid", "category", "provider"], name: "index_connections_on_uuid_and_category_and_provider", unique: true
  end

  create_table "contact_sequence_stage_activities", force: :cascade do |t|
    t.bigint "contact_sequence_stage_id", null: false
    t.integer "event_type", null: false
    t.jsonb "event_metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_sequence_stage_id"], name: "idx_on_contact_sequence_stage_id_3bc2586e1e"
  end

  create_table "contact_sequence_stages", force: :cascade do |t|
    t.bigint "contact_sequence_id", null: false
    t.bigint "sequence_stage_id", null: false
    t.bigint "message_sent_session_id"
    t.jsonb "stage_snapshot", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_sequence_id"], name: "index_contact_sequence_stages_on_contact_sequence_id"
    t.index ["message_sent_session_id"], name: "index_contact_sequence_stages_on_message_sent_session_id"
    t.index ["sequence_stage_id"], name: "index_contact_sequence_stages_on_sequence_stage_id"
  end

  create_table "contact_sequences", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.bigint "sequence_id", null: false
    t.bigint "connection_id", null: false
    t.integer "status", default: 0, null: false
    t.jsonb "variables", default: {}
    t.datetime "scheduled_at"
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["connection_id"], name: "index_contact_sequences_on_connection_id"
    t.index ["contact_id"], name: "index_contact_sequences_on_contact_id"
    t.index ["sequence_id"], name: "index_contact_sequences_on_sequence_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email_domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_contacts_on_account_id"
    t.index ["email"], name: "index_contacts_on_email", unique: true
    t.index ["email_domain"], name: "index_contacts_on_email_domain"
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "message_sent_sessions", force: :cascade do |t|
    t.bigint "connection_id", null: false
    t.string "message_id"
    t.string "thread_id"
    t.string "mail_id"
    t.integer "stage", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.jsonb "data_source_response", default: {}
    t.jsonb "data_source_message_details", default: {}
    t.string "raw_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["connection_id"], name: "index_message_sent_sessions_on_connection_id"
  end

  create_table "sequence_settings", force: :cascade do |t|
    t.bigint "sequence_id", null: false
    t.bigint "connection_id", null: false
    t.string "timezone"
    t.date "schedule_start_at"
    t.time "allowed_send_window_from"
    t.time "allowed_send_window_to"
    t.time "skip_time_window_from"
    t.time "skip_time_window_to"
    t.boolean "exit_on_sender_email_received", default: false, null: false
    t.boolean "exit_on_meeting_booked", default: false, null: false
    t.boolean "exit_all_same_domain", default: false, null: false
    t.boolean "exit_on_domain_reply", default: false, null: false
    t.boolean "tracking_opens", default: true, null: false
    t.boolean "tracking_clicks", default: true, null: false
    t.boolean "prevent_repeat_send", default: false, null: false
    t.boolean "prevent_multi_sequence_send", default: false, null: false
    t.boolean "prevent_repeat_send_in_groups", default: false, null: false
    t.string "cc_email", default: [], null: false, array: true
    t.string "bcc_email", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["connection_id"], name: "index_sequence_settings_on_connection_id"
    t.index ["sequence_id"], name: "index_sequence_settings_on_sequence_id", unique: true
  end

  create_table "sequence_stages", force: :cascade do |t|
    t.bigint "sequence_id", null: false
    t.integer "stage_index", default: 0, null: false
    t.string "subject"
    t.text "template"
    t.text "variables", default: [], array: true
    t.integer "perform_in_unit"
    t.integer "perform_in_period"
    t.integer "perform_reason", default: 0, null: false
    t.time "allowed_send_window_from"
    t.time "allowed_send_window_to"
    t.string "timezone"
    t.boolean "send_in_thread", default: true, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sequence_id", "stage_index"], name: "index_sequence_stages_on_sequence_id_and_stage_index"
    t.index ["sequence_id"], name: "index_sequence_stages_on_sequence_id"
  end

  create_table "sequences", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.string "name"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sequences_on_account_id"
    t.index ["user_id"], name: "index_sequences_on_user_id"
  end

  create_table "track_messages", force: :cascade do |t|
    t.bigint "message_sent_session_id", null: false
    t.string "tracking_key", null: false
    t.integer "action_type", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_sent_session_id"], name: "index_track_messages_on_message_sent_session_id"
    t.index ["tracking_key"], name: "index_track_messages_on_tracking_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "account_users", "accounts"
  add_foreign_key "account_users", "users"
  add_foreign_key "action_rule_associations", "action_rules"
  add_foreign_key "action_rule_dates", "action_rules"
  add_foreign_key "action_rules", "accounts"
  add_foreign_key "action_rules", "users"
  add_foreign_key "connections", "accounts"
  add_foreign_key "connections", "users"
  add_foreign_key "contact_sequence_stage_activities", "contact_sequence_stages"
  add_foreign_key "contact_sequence_stages", "contact_sequences"
  add_foreign_key "contact_sequence_stages", "message_sent_sessions"
  add_foreign_key "contact_sequence_stages", "sequence_stages"
  add_foreign_key "contact_sequences", "connections"
  add_foreign_key "contact_sequences", "contacts"
  add_foreign_key "contact_sequences", "sequences"
  add_foreign_key "contacts", "accounts"
  add_foreign_key "contacts", "users"
  add_foreign_key "message_sent_sessions", "connections"
  add_foreign_key "sequence_settings", "connections"
  add_foreign_key "sequence_settings", "sequences"
  add_foreign_key "sequence_stages", "sequences"
  add_foreign_key "sequences", "accounts"
  add_foreign_key "sequences", "users"
  add_foreign_key "track_messages", "message_sent_sessions"
end
