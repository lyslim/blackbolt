class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.confirmable
      t.recoverable
      t.rememberable
      t.trackable
      # t.lockable
      
      #t.integer  "sex"
      #t.date     "birthday"
      #t.string   "company_name",   :limit => 60
      #t.string   "section_name",   :limit => 60
      #t.string   "zip",            :limit => 8
      #t.string   "prefecture",     :limit => 10
      #t.string   "address1",       :limit => 100
      #t.string   "address2",       :limit => 100
      #t.string   "tel",            :limit => 14
      #t.string   "fax",            :limit => 14
      #t.date     "start_date"
      #t.date     "expire_date"
      #t.datetime "created_on",                                   :null => false
      #t.datetime "updated_on",                                   :null => false
      #t.string   "srcpassword"
      #t.string   "skype_id"
      #t.datetime "last_login_on"

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end

  def self.down
    drop_table :users
  end
end
