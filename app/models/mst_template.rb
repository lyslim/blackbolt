class MstTemplate < ActiveRecord::Base

  # (1:n)
  has_many :mst_compositions, :foreign_key => "template_id", :dependent=>:destroy

end
