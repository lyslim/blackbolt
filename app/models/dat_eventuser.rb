class DatEventuser < ActiveRecord::Base

  # (1:n)
  belongs_to :dat_event, :foreign_key=>"event_id"

  # (1:n)
  belongs_to :dat_projectuser, :foreign_key=>"projectuser_id"

end
