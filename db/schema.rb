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

ActiveRecord::Schema[8.1].define(version: 2026_04_14_044220) do
  create_table "bookings", force: :cascade do |t|
    t.string "booking_type", default: "standard", null: false
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.integer "equipment_id"
    t.datetime "locked_at"
    t.integer "locked_by_id"
    t.text "notes"
    t.integer "quantity"
    t.datetime "start_time"
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "venue_id"
    t.index ["booking_type"], name: "index_bookings_on_booking_type"
    t.index ["equipment_id", "start_time", "end_time", "status"], name: "idx_on_equipment_id_start_time_end_time_status_254d8b5721"
    t.index ["locked_by_id"], name: "index_bookings_on_locked_by_id"
    t.index ["venue_id", "start_time", "end_time", "status"], name: "idx_on_venue_id_start_time_end_time_status_5cb8ddd9f5"
  end

  create_table "equipment", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.float "latitude"
    t.string "location"
    t.float "longitude"
    t.string "name"
    t.integer "quantity"
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_equipment_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.integer "tenant_id"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
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
    t.integer "tenant_id"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_venues_on_tenant_id"
  end

  add_foreign_key "equipment", "tenants"
  add_foreign_key "venues", "tenants"
end
