# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_08_061346) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "notifications", force: :cascade do |t|
    t.string "number"
    t.text "message"
    t.string "status"
    t.uuid "external_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "notification_id"
    t.bigint "provider_id"
    t.index ["external_id"], name: "index_notifications_on_external_id"
    t.index ["notification_id"], name: "index_notifications_on_notification_id"
    t.index ["number"], name: "index_notifications_on_number"
    t.index ["provider_id"], name: "index_notifications_on_provider_id"
    t.index ["status"], name: "index_notifications_on_status"
  end

  create_table "providers", force: :cascade do |t|
    t.string "url"
    t.float "weight"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "notifications", "notifications"
  add_foreign_key "notifications", "providers"
end
