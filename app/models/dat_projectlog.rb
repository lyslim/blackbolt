class DatProjectlog < ActiveRecord::Base

  #########################
  # Related definitions
  #########################
  # Owned by the project configuration data(1:1)
  belongs_to :dat_projectcomp, :foreign_key => "projectcomp_id"

end
