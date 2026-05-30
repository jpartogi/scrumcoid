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

ActiveRecord::Schema[8.1].define(version: 2026_05_23_003000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "about_pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "summary", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blog_posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.text "excerpt", null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
    t.index ["status", "published_at"], name: "index_blog_posts_on_status_and_published_at"
  end

  create_table "class_schedule_prices", force: :cascade do |t|
    t.float "amount", null: false
    t.bigint "class_schedule_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", null: false
    t.datetime "updated_at", null: false
    t.index ["class_schedule_id", "currency"], name: "index_class_schedule_prices_on_class_schedule_id_and_currency", unique: true
    t.index ["class_schedule_id"], name: "index_class_schedule_prices_on_class_schedule_id"
  end

  create_table "class_schedules", force: :cascade do |t|
    t.integer "capacity", default: 20, null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.string "location", null: false
    t.boolean "online", default: true, null: false
    t.datetime "registration_deadline", null: false
    t.datetime "starts_at", null: false
    t.integer "status", default: 0, null: false
    t.string "timezone", default: "Australia/Brisbane", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_class_schedules_on_course_id"
    t.index ["starts_at"], name: "index_class_schedules_on_starts_at"
    t.index ["status"], name: "index_class_schedules_on_status"
  end

  create_table "contact_messages", force: :cascade do |t|
    t.string "company"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.string "subject", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_contact_messages_on_created_at"
    t.index ["status"], name: "index_contact_messages_on_status"
  end

  create_table "course_prices", force: :cascade do |t|
    t.float "amount", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "currency"], name: "index_course_prices_on_course_id_and_currency", unique: true
    t.index ["course_id"], name: "index_course_prices_on_course_id"
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.text "excerpt", null: false
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_courses_on_slug", unique: true
    t.index ["status"], name: "index_courses_on_status"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "amount_paid_cents"
    t.bigint "class_schedule_id", null: false
    t.datetime "created_at", null: false
    t.string "currency"
    t.datetime "paid_at"
    t.integer "status", default: 0, null: false
    t.string "stripe_checkout_session_id"
    t.string "stripe_payment_intent_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "visitor_email"
    t.string "visitor_name"
    t.index ["class_schedule_id"], name: "index_enrollments_on_class_schedule_id"
    t.index ["stripe_checkout_session_id"], name: "index_enrollments_on_stripe_checkout_session_id", unique: true
    t.index ["stripe_payment_intent_id"], name: "index_enrollments_on_stripe_payment_intent_id"
    t.index ["user_id", "class_schedule_id"], name: "index_enrollments_on_user_id_and_class_schedule_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
    t.index ["visitor_email", "class_schedule_id"], name: "index_enrollments_on_visitor_email_and_class_schedule_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "class_schedule_prices", "class_schedules"
  add_foreign_key "class_schedules", "courses"
  add_foreign_key "course_prices", "courses"
  add_foreign_key "enrollments", "class_schedules"
  add_foreign_key "enrollments", "users"
end
