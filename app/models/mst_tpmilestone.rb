class MstTpmilestone < ActiveRecord::Base

  # (1:1)
  belongs_to :mst_composition, :foreign_key => "template_tree_id"

end
