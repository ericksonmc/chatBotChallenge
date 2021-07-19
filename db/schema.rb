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

ActiveRecord::Schema.define(version: 2021_07_19_011155) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bots", force: :cascade do |t|
    t.string "username"
    t.string "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_bots_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.float "amount"
    t.integer "status"
    t.date "date_to_send"
    t.string "rut"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["rut"], name: "index_orders_on_rut"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "paper_requests", force: :cascade do |t|
    t.string "rut"
    t.integer "quantity"
    t.bigint "user_id", null: false
    t.float "amount", default: 0.0
    t.text "address"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "order_id"
    t.index ["user_id"], name: "index_paper_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.integer "telegram_id"
    t.integer "rut"
    t.integer "step"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "bots", "users"
  add_foreign_key "orders", "users"
  add_foreign_key "paper_requests", "users"
end
