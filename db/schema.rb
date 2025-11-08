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

ActiveRecord::Schema[8.1].define(version: 2025_11_08_152445) do
  create_table "stages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "difficulty"
    t.integer "stage_guid"
    t.string "stage_number"
    t.text "tips"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["stage_guid"], name: "index_stages_on_stage_guid"
    t.index ["user_id"], name: "index_stages_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "email IS NOT NULL AND email != ''"
    t.index ["username"], name: "index_users_on_username", unique: true
  end
end
