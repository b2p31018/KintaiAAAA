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

ActiveRecord::Schema.define(version: 20231015134018) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "overtime_work"
    t.datetime "tomorrow_edit"
    t.datetime "started_edit_at"
    t.datetime "finished_edit_at"
    t.string "indicater_check"
    t.integer "indicater_reply", default: 0
    t.integer "indicater_reply_edit", default: 0
    t.string "indicater_check_edit"
    t.string "indicater_check_anser"
    t.string "indicater_check_edit_anser"
    t.integer "indicater_reply_month", default: 0
    t.string "indicater_check_month"
    t.string "indicater_check_month_anser"
    t.datetime "overtime_finished_at"
    t.boolean "tomorrow", default: false
    t.boolean "change", default: false
    t.boolean "change_edit", default: false
    t.datetime "started_before_at"
    t.datetime "finished_before_at"
    t.date "month_approval"
    t.boolean "change_month", default: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "base_number"
    t.string "base_name"
    t.string "information"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2023-10-09 23:00:00"
    t.datetime "work_time", default: "2023-10-09 22:30:00"
    t.boolean "superior", default: false
    t.string "affiliation"
    t.string "employee_number"
    t.string "uid"
    t.datetime "designated_work_start_time", default: "2023-10-10 00:00:00"
    t.datetime "designated_work_end_time", default: "2023-10-10 09:00:00"
    t.datetime "basic_work_time", default: "2023-10-09 23:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
