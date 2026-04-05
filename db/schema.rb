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

ActiveRecord::Schema[8.1].define(version: 2026_04_05_153127) do
  create_table "bookings", force: :cascade do |t|
    t.string "booking_type", null: false
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.integer "equipment_id"
    t.text "notes"
    t.datetime "start_time"
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "venue_id"
    t.index ["booking_type"], name: "index_bookings_on_booking_type"
  end

  create_table "equipment", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.float "latitude"
    t.string "location"
    t.float "longitude"
    t.string "name"
    t.integer "quantity"
    t.datetime "updated_at", null: false
  end

  create_table "tenants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.integer "capacity"
    t.time "close_time"
    t.datetime "created_at", null: false
    t.text "description"
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.time "open_time"
    t.datetime "updated_at", null: false
  end
end
