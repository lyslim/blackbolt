class DatTaskhistory < ActiveRecord::Base

  # (1:n)
  belongs_to :dat_task
  belongs_to :update_user, :class_name => 'User', :foreign_key => 'update_user_id'

end
