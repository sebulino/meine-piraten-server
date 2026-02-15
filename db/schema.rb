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

ActiveRecord::Schema[8.1].define(version: 2026_02_15_203452) do
  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string "author_name"
    t.datetime "created_at", null: false
    t.integer "task_id", null: false
    t.text "text"
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_comments_on_task_id"
  end

  create_table "entities", force: :cascade do |t|
    t.boolean "KV"
    t.boolean "LV"
    t.boolean "OV"
    t.datetime "created_at", null: false
    t.integer "entity_id"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "activity_points"
    t.string "assignee"
    t.integer "category_id", null: false
    t.boolean "completed"
    t.datetime "created_at", null: false
    t.string "creator_name"
    t.text "description"
    t.date "due_date"
    t.integer "entity_id", null: false
    t.string "status", default: "open"
    t.integer "time_needed_in_hours"
    t.string "title"
    t.datetime "updated_at", null: false
    t.boolean "urgent"
    t.index ["category_id"], name: "index_tasks_on_category_id"
    t.index ["entity_id"], name: "index_tasks_on_entity_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "preferred_username"
    t.string "provider", default: "openid_connect", null: false
    t.text "refresh_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "token_expires_at"
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "comments", "tasks"
  add_foreign_key "tasks", "categories"
  add_foreign_key "tasks", "entities"
end
