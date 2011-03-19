class DatProjectuser < ActiveRecord::Base

  # (1:n)
  belongs_to :dat_project, :foreign_key => "project_id"
  
  # (1:n)
  belongs_to :user, :foreign_key=>"user_id"

  # (1:n)
  has_many :dat_taskusers, :foreign_key=>"projectuser_id", :dependent=>:destroy
  # (1:n)
  has_many :dat_eventusers, :foreign_key=>"projectuser_id", :dependent=>:destroy

  # Sponser (1:n)　
  has_many :dat_task_client, :class_name=>"DatTask", :foreign_key=>"client_user_id", :dependent=>:nullify
  # Main person in charger(1:n)
  has_many :dat_task_main, :class_name=>"DatTask", :foreign_key=>"main_user_id", :dependent=>:nullify

end
