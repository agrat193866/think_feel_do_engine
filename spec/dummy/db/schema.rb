# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140903134021) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: true do |t|
    t.integer  "participant_id",                                     null: false
    t.integer  "activity_type_id",                                   null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "actual_accomplishment_intensity"
    t.integer  "actual_pleasure_intensity"
    t.integer  "predicted_accomplishment_intensity"
    t.integer  "predicted_pleasure_intensity"
    t.boolean  "is_complete",                        default: false, null: false
    t.text     "noncompliance_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_monitored",                       default: false, null: false
    t.boolean  "is_scheduled",                       default: false, null: false
  end

  add_index "activities", ["activity_type_id"], name: "index_activities_on_activity_type_id", using: :btree
  add_index "activities", ["participant_id"], name: "index_activities_on_participant_id", using: :btree

  create_table "activity_types", force: true do |t|
    t.integer  "participant_id"
    t.string   "title",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_types", ["participant_id"], name: "index_activity_types_on_participant_id", using: :btree

  create_table "awake_periods", force: true do |t|
    t.integer  "participant_id", null: false
    t.datetime "start_time",     null: false
    t.datetime "end_time",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "awake_periods", ["participant_id"], name: "index_awake_periods_on_participant_id", using: :btree

  create_table "bit_core_content_modules", force: true do |t|
    t.string   "title",                        null: false
    t.integer  "position",         default: 1, null: false
    t.integer  "bit_core_tool_id",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "bit_core_content_modules", ["bit_core_tool_id", "position"], name: "bit_core_content_module_position", unique: true, using: :btree

  create_table "bit_core_content_providers", force: true do |t|
    t.string   "type",                                   null: false
    t.string   "source_content_type"
    t.integer  "source_content_id"
    t.integer  "bit_core_content_module_id",             null: false
    t.integer  "position",                   default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "template_path"
    t.string   "data_class_name"
    t.text     "data_attributes"
    t.boolean  "show_next_nav"
    t.text     "locals"
  end

  add_index "bit_core_content_providers", ["bit_core_content_module_id", "position"], name: "bit_core_content_provider_position", unique: true, using: :btree

  create_table "bit_core_slides", force: true do |t|
    t.string   "title",                                null: false
    t.text     "body",                                 null: false
    t.integer  "position",              default: 1,    null: false
    t.integer  "bit_core_slideshow_id",                null: false
    t.string   "type"
    t.boolean  "is_title_visible",      default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "options"
  end

  add_index "bit_core_slides", ["bit_core_slideshow_id", "position"], name: "bit_core_slide_position", unique: true, using: :btree

  create_table "bit_core_slideshows", force: true do |t|
    t.string   "title",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bit_core_tools", force: true do |t|
    t.string   "title",                  null: false
    t.integer  "position",   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bit_core_tools", ["position"], name: "bit_core_tool_position", unique: true, using: :btree

  create_table "bit_player_participant_statuses", force: true do |t|
    t.string   "context"
    t.integer  "module_position"
    t.integer  "provider_position"
    t.integer  "content_position"
    t.integer  "participant_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bit_player_participant_statuses", ["participant_id"], name: "index_participant_statuses_on_participant_id", using: :btree

  create_table "coach_assignments", force: true do |t|
    t.integer  "participant_id", null: false
    t.integer  "coach_id",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coach_assignments", ["coach_id"], name: "index_coach_assignments_on_coach_id", using: :btree
  add_index "coach_assignments", ["participant_id"], name: "index_coach_assignments_on_participant_id", using: :btree

  create_table "content_provider_policies", force: true do |t|
    t.boolean  "is_skippable_after_first_viewing", default: false, null: false
    t.integer  "bit_core_content_provider_id",                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivered_messages", force: true do |t|
    t.integer  "message_id",                     null: false
    t.integer  "recipient_id",                   null: false
    t.string   "recipient_type",                 null: false
    t.boolean  "is_read",        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delivered_messages", ["message_id"], name: "index_delivered_messages_on_message_id", using: :btree
  add_index "delivered_messages", ["recipient_id", "recipient_type"], name: "index_delivered_messages_on_recipient_id_and_recipient_type", using: :btree

  create_table "emotional_ratings", force: true do |t|
    t.integer  "participant_id", null: false
    t.integer  "emotion_id",     null: false
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emotions", force: true do |t|
    t.integer  "creator_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       null: false
  end

  add_index "emotions", ["creator_id"], name: "index_emotions_on_creator_id", using: :btree

  create_table "engagements", force: true do |t|
    t.integer  "task_status_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_capture_events", force: true do |t|
    t.datetime "emitted_at"
    t.datetime "recorded_at"
    t.text     "payload"
    t.string   "user_id"
    t.string   "user_agent"
    t.string   "source"
    t.string   "kind"
    t.integer  "participant_id", null: false
  end

  create_table "groups", force: true do |t|
    t.string   "title",      null: false
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["title"], name: "index_groups_on_title", unique: true, using: :btree

  create_table "memberships", force: true do |t|
    t.integer  "group_id",       null: false
    t.integer  "participant_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
  end

  add_index "memberships", ["group_id", "participant_id"], name: "index_memberships_on_group_id_and_participant_id", unique: true, using: :btree
  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree
  add_index "memberships", ["participant_id"], name: "index_memberships_on_participant_id", using: :btree

  create_table "messages", force: true do |t|
    t.integer  "sender_id",      null: false
    t.string   "sender_type",    null: false
    t.integer  "recipient_id",   null: false
    t.string   "recipient_type", null: false
    t.string   "subject",        null: false
    t.text     "body"
    t.datetime "sent_at",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["recipient_id", "recipient_type"], name: "index_messages_on_recipient_id_and_recipient_type", using: :btree
  add_index "messages", ["sender_id", "sender_type"], name: "index_messages_on_sender_id_and_sender_type", using: :btree

  create_table "moods", force: true do |t|
    t.integer  "participant_id", null: false
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "moods", ["participant_id"], name: "index_moods_on_participant_id", using: :btree

  create_table "participant_login_events", force: true do |t|
    t.integer  "participant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "inactive_log_out", default: false
    t.datetime "signed_out_at"
  end

  add_index "participant_login_events", ["participant_id"], name: "index_participant_login_events_on_participant_id", using: :btree

  create_table "participant_tokens", force: true do |t|
    t.integer  "participant_id", null: false
    t.date     "release_date"
    t.string   "token_type",     null: false
    t.string   "token",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participant_tokens", ["participant_id", "token"], name: "index_participant_tokens_on_participant_id_and_token", unique: true, using: :btree
  add_index "participant_tokens", ["participant_id"], name: "index_participant_tokens_on_participant_id", using: :btree

  create_table "participants", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "study_id"
  end

  add_index "participants", ["email"], name: "index_participants_on_email", unique: true, using: :btree
  add_index "participants", ["reset_password_token"], name: "index_participants_on_reset_password_token", unique: true, using: :btree

  create_table "phq_assessments", force: true do |t|
    t.date     "release_date",   null: false
    t.integer  "q1"
    t.integer  "q2"
    t.integer  "q3"
    t.integer  "q4"
    t.integer  "q5"
    t.integer  "q6"
    t.integer  "q7"
    t.integer  "q8"
    t.integer  "q9"
    t.integer  "participant_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "q1_editor_id"
    t.integer  "q2_editor_id"
    t.integer  "q3_editor_id"
    t.integer  "q4_editor_id"
    t.integer  "q5_editor_id"
    t.integer  "q6_editor_id"
    t.integer  "q7_editor_id"
    t.integer  "q8_editor_id"
    t.integer  "q9_editor_id"
  end

  add_index "phq_assessments", ["participant_id", "release_date"], name: "index_phq_assessments_on_participant_id_and_release_date", unique: true, using: :btree
  add_index "phq_assessments", ["participant_id"], name: "index_phq_assessments_on_participant_id", using: :btree

  create_table "slideshow_anchors", force: true do |t|
    t.integer  "bit_core_slideshow_id", null: false
    t.string   "target_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_statuses", force: true do |t|
    t.integer  "membership_id", null: false
    t.integer  "task_id",       null: false
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "start_day"
  end

  create_table "tasks", force: true do |t|
    t.integer  "group_id",                                   null: false
    t.integer  "bit_core_content_module_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id"
    t.integer  "release_day"
    t.boolean  "is_recurring",               default: false, null: false
    t.integer  "termination_day"
    t.boolean  "has_didactic_content",       default: true,  null: false
  end

  add_index "tasks", ["bit_core_content_module_id"], name: "index_tasks_on_bit_core_content_module_id", using: :btree
  add_index "tasks", ["group_id"], name: "index_tasks_on_group_id", using: :btree

  create_table "thought_patterns", force: true do |t|
    t.string   "title",                        null: false
    t.text     "description",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "explanation"
    t.string   "question"
    t.text     "recommendations", default: "", null: false
  end

  create_table "thoughts", force: true do |t|
    t.text     "content",             null: false
    t.string   "effect",              null: false
    t.integer  "participant_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pattern_id"
    t.text     "challenging_thought"
    t.text     "act_as_if"
  end

  add_index "thoughts", ["participant_id"], name: "index_thoughts_on_participant_id", using: :btree

  create_table "user_roles", force: true do |t|
    t.integer  "user_id",         null: false
    t.string   "role_class_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_roles", ["role_class_name", "user_id"], name: "index_user_roles_on_role_class_name_and_user_id", unique: true, using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",               default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
