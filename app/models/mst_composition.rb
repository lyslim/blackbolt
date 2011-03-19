class MstComposition < ActiveRecord::Base

  # (1:n)
  belongs_to :mst_template, :foreign_key => "template_id"
  # (1:1)
  has_one :mst_tptask, :foreign_key => "template_tree_id", :dependent=>:destroy
  # (1:1)
  has_one :mst_tpmilestone, :foreign_key => "template_tree_id", :dependent=>:destroy
  # (1:1)
  has_one :mst_tpevent, :foreign_key => "template_tree_id", :dependent=>:destroy

end
