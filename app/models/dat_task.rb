class DatTask < ActiveRecord::Base

  #########################
  # Related Definitions
  #########################
  # owned by the project configuration data(1:1)
  belongs_to :dat_projectcomp, :foreign_key => "project_tree_id"
  # task users(1:n)
  has_many :dat_taskusers, :foreign_key => "task_id", :dependent=>:destroy
  # task owns hostorical data(1:n)
  has_many :dat_taskhistories  , :foreign_key => "task_id", :dependent=>:destroy

  # project requester(1:n)
  belongs_to :dat_user_client, :class_name=>"DatProjectuser", :foreign_key=>"client_user_id"
  # task owner(1:n)
  belongs_to :dat_user_main, :class_name=>"DatProjectuser", :foreign_key=>"main_user_id"

  #########################
  # filter
  #########################
  before_create :create_taskcd

  ###########################################################
  # method: copyFromTemplate
  # abstract: data for the specified template (TP task master) and
  #  copy the attribute values
  # argument: template TP task master (mst_tptask) Object
  # returns: none
  ###########################################################
  def copyFromTemplate(template)
    self.attributes.each_pair do | key, value |
      case key.to_s
      when "create_user_id"
      when "created_on"
      when "update_user_id"
      when "updated_on"
      else
        if ! template[key.to_s].nil?
          self[key.to_s] = template[key.to_s]
        end
      end
    end

  end

  def create_taskcd
    project_id = self.dat_projectcomp.project_id
    if ! project_id.nil?
      count = DatProjectcomp.count( :conditions=>[" project_id=? AND task_kbn=1 ",project_id] )  
      task_cd = sprintf("T%03d", count)
      write_attribute("task_cd", task_cd)
    end
  end

  def after_update
    if self.last_operation_kbn == 4
      projectlog = self.dat_projectcomp.dat_projectlogs.build
      if self.progress_kbn == 3
        projectlog.log_kbn = 5
      else
        projectlog.log_kbn = 4
      end
      projectlog.create_user_id = self.create_user_id
      projectlog.save
    end
  end
end
