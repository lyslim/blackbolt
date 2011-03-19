class DatProjectcomp < ActiveRecord::Base

  #########################
  # Related definitions
  #########################
  # (1:n)
  belongs_to :dat_project, :foreign_key => "project_id"
  # milestone(1:1)
  has_one :dat_milestone, :foreign_key => "project_tree_id", :dependent=>:destroy
  # task(1:1)
  has_one :dat_task, :foreign_key => "project_tree_id", :dependent=>:destroy
  # event(1:1)
  has_one :dat_event, :foreign_key => "project_tree_id", :dependent=>:destroy
  # project logs(1:n)
  has_many :dat_projectlogs, :foreign_key => "projectcomp_id"

  # (1:n)
  belongs_to :mst_user_create, :class_name=>"User", :foreign_key=>"create_user_id"
  # (1:n)
  belongs_to :mst_user_update, :class_name=>"User", :foreign_key=>"update_user_id"

  TASK_KBN = {
    1 => :task,
    2 => :milestone,
    3 => :event,
  }

  # task_kbn
  def taskkbn
    TASK_KBN[task_kbn]
  end

  def comp_item
    item = case taskkbn
           when :task      then dat_task
           when :milestone then dat_milestone
           when :event     then dat_event
           end
    item
  end

  # start_date
  def get_dates
    item = comp_item()
    dates = case taskkbn
           when :task      then [item.start_date, item.end_date]
           when :milestone then [item.mils_date, nil]
           when :event     then [item.start_date, nil]
           end
    dates
  end

  def comp_name
    
  end

  ###########################################################
  # method：copyFromTemplate
  # abstract：data for the specified template (master template configuration) to copy the attribute values
  # argument：template master template configuration (mst_composition) Object
  # return: none
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

    if ! template.mst_tptask.nil?
      task = DatTask.new
      task.create_user_id = self.create_user_id
      task.update_user_id = self.update_user_id
      task.last_operation_kbn = 1
      task.copyFromTemplate(template.mst_tptask)
      self.dat_task = task 
    end

    if ! template.mst_tpmilestone.nil?
      milestone = DatMilestone.new
      milestone.create_user_id = self.create_user_id
      milestone.update_user_id = self.update_user_id
      milestone.last_operation_kbn = 1
      milestone.copyFromTemplate(template.mst_tpmilestone)
      self.dat_milestone = milestone 
    end

    if ! template.mst_tpevent.nil?
      event = DatEvent.new
      event.create_user_id = self.create_user_id
      event.update_user_id = self.update_user_id
      event.last_operation_kbn = 1
      event.copyFromTemplate(template.mst_tpevent)
      self.dat_event = event 
    end

  end


  def after_create
    projectlog = self.dat_projectlogs.build
    projectlog.log_kbn = 1
    projectlog.create_user_id = self.create_user_id
    projectlog.save
  end
  def after_update
    projectlog = self.dat_projectlogs.build
    projectlog.log_kbn = 2
    projectlog.create_user_id = self.create_user_id
    projectlog.save
  end
  def after_destroy
    projectlog = self.dat_projectlogs.build
    projectlog.log_kbn = 3
    projectlog.create_user_id = self.create_user_id
    projectlog.save
  end

end
