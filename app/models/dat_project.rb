class DatProject < ActiveRecord::Base

  # (1:n)
  has_many :dat_projectcomps, :foreign_key => "project_id", :dependent=>:destroy
  # (1:n)
  has_many :dat_projectusers, :foreign_key => "project_id", :dependent=>:destroy
  has_many :users,  :through => :dat_projectusers

  def self.find_project_and_users(project_id, user_id)
    opt = {
      :conditions => ["dat_projects.id = ? AND dat_projectusers.user_id = ? ", project_id, user_id],
      :include    => :dat_projectusers
    }
    find(:first, opt)
  end

  def copyFromTemplate(template)
    for composition in template.mst_compositions
      projectcomp = self.dat_projectcomps.build
      projectcomp.create_user_id = self.create_user_id
      projectcomp.update_user_id = self.update_user_id
      projectcomp.last_operation_kbn = 1
      projectcomp.copyFromTemplate(composition)
    end
  end

end
