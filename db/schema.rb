# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170605011641) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.decimal  "price"
    t.integer  "merchant_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["merchant_id"], name: "index_items_on_merchant_id", using: :btree
  end

  create_table "merchants", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "user_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.decimal  "fee",         precision: 5, scale: 4, default: "0.0"
    t.index ["user_id"], name: "index_merchants_on_user_id", using: :btree
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "merchant_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "item_id"
    t.decimal  "total",         precision: 8, scale: 2, default: "0.0", null: false
    t.boolean  "paid",                                  default: false
    t.string   "stripe_charge"
    t.decimal  "fee_charged",   precision: 5, scale: 4, default: "0.0"
    t.index ["merchant_id"], name: "index_transactions_on_merchant_id", using: :btree
    t.index ["user_id"], name: "index_transactions_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                          default: "",    null: false
    t.string   "encrypted_password",                             default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                  default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.boolean  "admin",                                          default: false
    t.decimal  "credit",                 precision: 8, scale: 2, default: "0.0", null: false
    t.string   "uid"
    t.string   "provider"
    t.string   "access_code"
    t.string   "publishable_key"
    t.string   "stripe_customer_id"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "items", "merchants"
  add_foreign_key "merchants", "users"
  add_foreign_key "transactions", "merchants"
  add_foreign_key "transactions", "users"
end
