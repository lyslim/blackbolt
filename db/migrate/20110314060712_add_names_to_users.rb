class AddNamesToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string   "sap_name",        :null => false
      t.string   "user_num"
      t.index    "sap_name",        :unique => true
      t.index    "user_num",        :unique => true
      t.string   "first_name"                                  
      t.string   "last_name"
      t.integer  "valid_flag",      :default => 1, :null => false
      t.integer  "create_user_id"
      t.integer  "update_user_id"
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :sap_name, :first_name, :last_name, :valid_flag, :create_user_id, :update_user_id, :user_num
    end 
  end
end
