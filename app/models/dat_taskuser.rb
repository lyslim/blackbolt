class DatTaskuser < ActiveRecord::Base

  #########################
  # Related definitions
  #########################
  # owned by task data(1:n)
  belongs_to :dat_task, :foreign_key=>"task_id"

  # owned by project users(1:n)
  belongs_to :dat_projectuser, :foreign_key=>"projectuser_id"

end
