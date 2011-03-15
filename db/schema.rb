# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110314060712) do

  create_table "dat_events", :force => true do |t|
    t.integer  "project_tree_id",                                  :null => false
    t.date     "start_date"
    t.time     "start_time"
    t.date     "end_date"
    t.time     "end_time"
    t.integer  "allday_kbn",                        :default => 1
    t.string   "place",              :limit => 100
    t.text     "content"
    t.integer  "create_user_id",                                   :null => false
    t.datetime "created_on",                                       :null => false
    t.integer  "update_user_id",                                   :null => false
    t.datetime "updated_on",                                       :null => false
    t.integer  "last_operation_kbn"
  end

  create_table "dat_eventusers", :force => true do |t|
    t.integer  "event_id",                      :null => false
    t.integer  "projectuser_id",                :null => false
    t.integer  "entry_flg",      :default => 0, :null => false
    t.integer  "create_user_id",                :null => false
    t.datetime "created_on",                    :null => false
  end

  create_table "dat_milestones", :force => true do |t|
    t.integer  "project_tree_id",    :null => false
    t.date     "mils_date"
    t.integer  "create_user_id",     :null => false
    t.datetime "created_on",         :null => false
    t.integer  "update_user_id",     :null => false
    t.datetime "updated_on",         :null => false
    t.integer  "last_operation_kbn"
  end

  create_table "dat_projectcomps", :force => true do |t|
    t.integer  "project_id",         :null => false
    t.integer  "line_no",            :null => false
    t.integer  "task_kbn",           :null => false
    t.string   "item_name",          :null => false
    t.string   "class_word1"
    t.string   "class_word2"
    t.string   "class_word3"
    t.integer  "create_user_id",     :null => false
    t.datetime "created_on",         :null => false
    t.integer  "update_user_id",     :null => false
    t.datetime "updated_on",         :null => false
    t.integer  "last_operation_kbn"
  end

  create_table "dat_projectlogs", :force => true do |t|
    t.integer  "projectcomp_id", :null => false
    t.integer  "log_kbn",        :null => false
    t.integer  "create_user_id", :null => false
    t.datetime "created_on",     :null => false
  end

  create_table "dat_projects", :force => true do |t|
    t.string   "project_cd",                    :null => false
    t.string   "project_name",                  :null => false
    t.date     "start_date"
    t.date     "delivery_date"
    t.integer  "valid_flg",      :default => 1, :null => false
    t.integer  "create_user_id",                :null => false
    t.datetime "created_on",                    :null => false
    t.integer  "update_user_id",                :null => false
    t.datetime "updated_on",                    :null => false
    t.string   "end_user_name"
  end

  create_table "dat_projectusers", :force => true do |t|
    t.integer  "project_id",                                  :null => false
    t.string   "email",          :limit => 40,                :null => false
    t.integer  "user_id"
    t.integer  "create_user_id",                              :null => false
    t.datetime "created_on",                                  :null => false
    t.integer  "active_flg",                   :default => 1
  end

  create_table "dat_taskhistories", :force => true do |t|
    t.integer  "task_id",                      :null => false
    t.string   "msg_code",       :limit => 20, :null => false
    t.text     "content",                      :null => false
    t.date     "report_date"
    t.integer  "update_user_id",               :null => false
    t.datetime "updated_on",                   :null => false
  end

  create_table "dat_tasks", :force => true do |t|
    t.integer  "project_tree_id",                     :null => false
    t.integer  "priority_kbn",       :default => 2,   :null => false
    t.float    "plan_power",         :default => 0.0, :null => false
    t.float    "fcas_power",         :default => 0.0
    t.float    "exp_power",          :default => 0.0
    t.integer  "tani_kbn",           :default => 2
    t.integer  "client_user_id"
    t.integer  "main_user_id"
    t.date     "complete_date"
    t.integer  "progress_kbn",       :default => 0
    t.integer  "progress_rate",      :default => 0
    t.text     "memo"
    t.integer  "create_user_id"
    t.datetime "created_on"
    t.integer  "update_user_id",                      :null => false
    t.datetime "updated_on",                          :null => false
    t.string   "task_cd"
    t.date     "start_date"
    t.date     "end_date"
    t.date     "report_date"
    t.text     "result"
    t.integer  "last_operation_kbn"
  end

  create_table "dat_taskusers", :force => true do |t|
    t.integer  "task_id",        :null => false
    t.integer  "projectuser_id", :null => false
    t.integer  "create_user_id", :null => false
    t.datetime "created_on",     :null => false
  end

  create_table "mst_compositions", :force => true do |t|
    t.integer  "template_id",    :null => false
    t.integer  "line_no",        :null => false
    t.integer  "task_kbn",       :null => false
    t.string   "item_name",      :null => false
    t.string   "class_word1"
    t.string   "class_word2"
    t.string   "class_word3"
    t.integer  "create_user_id", :null => false
    t.datetime "created_on",     :null => false
    t.integer  "update_user_id", :null => false
    t.datetime "updated_on",     :null => false
  end

  create_table "mst_messages", :force => true do |t|
    t.string   "msg_code",                      :null => false
    t.integer  "msg_kbn",                       :null => false
    t.text     "msg_base",                      :null => false
    t.text     "msg_jp",                        :null => false
    t.text     "msg_cn",                        :null => false
    t.text     "msg_en",                        :null => false
    t.integer  "valid_flg",      :default => 1, :null => false
    t.integer  "create_user_id"
    t.datetime "created_on",                    :null => false
    t.integer  "update_user_id"
    t.datetime "updated_on",                    :null => false
  end

  create_table "mst_templates", :force => true do |t|
    t.string   "type_name",      :limit => 40
    t.string   "template_name",  :limit => 100,                :null => false
    t.text     "memo"
    t.integer  "valid_flg",                     :default => 1, :null => false
    t.integer  "create_user_id",                               :null => false
    t.datetime "created_on",                                   :null => false
    t.integer  "update_user_id",                               :null => false
    t.datetime "updated_on",                                   :null => false
  end

  create_table "mst_tpevents", :force => true do |t|
    t.integer  "template_tree_id",                :null => false
    t.string   "place",            :limit => 100
    t.text     "content"
    t.integer  "create_user_id",                  :null => false
    t.datetime "created_on",                      :null => false
    t.integer  "update_user_id",                  :null => false
    t.datetime "updated_on",                      :null => false
  end

  create_table "mst_tpmilestones", :force => true do |t|
    t.integer  "template_tree_id", :null => false
    t.integer  "create_user_id",   :null => false
    t.datetime "created_on",       :null => false
    t.integer  "update_user_id",   :null => false
    t.datetime "updated_on",       :null => false
  end

  create_table "mst_tptasks", :force => true do |t|
    t.integer  "template_tree_id",                  :null => false
    t.float    "plan_power",       :default => 0.0
    t.integer  "tani_kbn",         :default => 2
    t.text     "memo"
    t.integer  "create_user_id",   :default => 2,   :null => false
    t.datetime "created_on",                        :null => false
    t.integer  "update_user_id",                    :null => false
    t.datetime "updated_on",                        :null => false
  end

  create_table "mst_users", :force => true do |t|
    t.string   "login_id"
    t.string   "password",                                     :null => false
    t.string   "user_name",                                    :null => false
    t.string   "email",                                        :null => false
    t.string   "name"
    t.integer  "sex"
    t.date     "birthday"
    t.string   "company_name",   :limit => 60
    t.string   "section_name",   :limit => 60
    t.string   "zip",            :limit => 8
    t.string   "prefecture",     :limit => 10
    t.string   "address1",       :limit => 100
    t.string   "address2",       :limit => 100
    t.string   "tel",            :limit => 14
    t.string   "fax",            :limit => 14
    t.date     "start_date"
    t.date     "expire_date"
    t.integer  "valid_flg",                     :default => 1, :null => false
    t.integer  "create_user_id"
    t.datetime "created_on",                                   :null => false
    t.integer  "update_user_id"
    t.datetime "updated_on",                                   :null => false
    t.string   "srcpassword"
    t.string   "skype_id"
    t.datetime "last_login_on"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sap_name",                                            :null => false
    t.string   "user_id",                                             :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "valid_flag",                          :default => 1,  :null => false
    t.integer  "create_user_id"
    t.integer  "update_user_id"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["sap_name"], :name => "index_users_on_sap_name", :unique => true
  add_index "users", ["user_id"], :name => "index_users_on_user_id", :unique => true

end
