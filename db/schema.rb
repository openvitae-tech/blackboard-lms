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

ActiveRecord::Schema[7.1].define(version: 2024_10_21_122945) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
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
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "course_modules", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lessons_count", default: 0
    t.integer "quizzes_count", default: 0
    t.bigint "lessons_in_order", default: [], array: true
    t.bigint "quizzes_in_order", default: [], array: true
    t.index ["course_id"], name: "index_course_modules_on_course_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "banner"
    t.integer "course_modules_count", default: 0
    t.integer "enrollments_count", default: 0
    t.bigint "course_modules_in_order", default: [], array: true
    t.boolean "is_published", default: false
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_module_id"
    t.integer "current_lesson_id"
    t.bigint "assigned_by_id"
    t.bigint "completed_lessons", default: [], array: true
    t.integer "time_spent", default: 0
    t.datetime "deadline_at"
    t.bigint "completed_modules", default: [], array: true
    t.boolean "course_completed", default: false
    t.index ["assigned_by_id"], name: "index_enrollments_on_assigned_by_id"
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id"], name: "index_enrollments_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.integer "partner_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.jsonb "data", default: {}, null: false
  end

  create_table "learning_partners", force: :cascade do |t|
    t.string "name"
    t.text "about"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo"
    t.string "banner"
    t.string "state", default: "new"
    t.boolean "first_owner_joined", default: false
  end

  create_table "lessons", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "video_url"
    t.string "pdf_url"
    t.string "lesson_type"
    t.string "video_streaming_source"
    t.bigint "course_module_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration", default: 0
    t.index ["course_module_id"], name: "index_lessons_on_course_module_id"
  end

  create_table "local_contents", force: :cascade do |t|
    t.string "lang"
    t.string "video_url"
    t.bigint "lesson_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_local_contents_on_lesson_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "ntype"
    t.string "text"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "quiz_answers", force: :cascade do |t|
    t.string "status"
    t.bigint "quiz_id", null: false
    t.bigint "enrollment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "answer"
    t.index ["enrollment_id"], name: "index_quiz_answers_on_enrollment_id"
    t.index ["quiz_id"], name: "index_quiz_answers_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "question"
    t.string "quiz_type"
    t.string "option_a"
    t.string "option_b"
    t.string "option_c"
    t.string "option_d"
    t.string "answer"
    t.bigint "course_module_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_module_id"], name: "index_quizzes_on_course_module_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "banner"
    t.bigint "learning_partner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_team_id"
    t.index ["learning_partner_id"], name: "index_teams_on_learning_partner_id"
    t.index ["parent_team_id"], name: "index_teams_on_parent_team_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.bigint "learning_partner_id"
    t.string "temp_password_enc"
    t.bigint "manager_id"
    t.string "phone"
    t.integer "enrollments_count", default: 0
    t.bigint "team_id"
    t.integer "otp"
    t.datetime "otp_generated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["learning_partner_id"], name: "index_users_on_learning_partner_id"
    t.index ["manager_id"], name: "index_users_on_manager_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "course_modules", "courses"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "users"
  add_foreign_key "enrollments", "users", column: "assigned_by_id"
  add_foreign_key "lessons", "course_modules"
  add_foreign_key "local_contents", "lessons"
  add_foreign_key "notifications", "users"
  add_foreign_key "quiz_answers", "enrollments"
  add_foreign_key "quiz_answers", "quizzes"
  add_foreign_key "quizzes", "course_modules"
  add_foreign_key "teams", "learning_partners"
  add_foreign_key "users", "learning_partners"
  add_foreign_key "users", "teams"
end
