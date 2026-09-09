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

ActiveRecord::Schema[8.1].define(version: 2026_09_09_183104) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "case_files", force: :cascade do |t|
    t.text "ai_summary"
    t.bigint "case_id", null: false
    t.datetime "created_at", null: false
    t.string "document_number"
    t.string "file_type"
    t.string "state"
    t.string "title"
    t.text "transcript"
    t.datetime "updated_at", null: false
    t.index ["case_id"], name: "index_case_files_on_case_id"
  end

  create_table "cases", force: :cascade do |t|
    t.boolean "consent", default: false, null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "representative_id"
    t.string "status", default: "pending", null: false
    t.text "summary"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["representative_id"], name: "index_cases_on_representative_id"
    t.index ["user_id"], name: "index_cases_on_user_id"
  end

  create_table "chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["chat_id", "created_at"], name: "index_messages_on_chat_id_and_created_at"
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "users", force: :cascade do |t|
    t.date "birth_date"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "gender"
    t.string "last_name"
    t.string "name"
    t.string "phone_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "user", null: false
    t.string "sex"
    t.string "state"
    t.datetime "updated_at", null: false
    t.string "user_country"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "case_files", "cases"
  add_foreign_key "cases", "users"
  add_foreign_key "cases", "users", column: "representative_id"
  add_foreign_key "chats", "users"
  add_foreign_key "messages", "chats"
end
