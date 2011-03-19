module TasksHelper

  def select_for_projects(variable, attribute, projectcomp, projects, options, html_options)
    if projectcomp.id.nil? || projectcomp.id == ""

      collection_select( variable, attribute, 
                         projects, 
                         :id, :project_name, 
                         options, html_options )
    else
      '<span>' + projectcomp.dat_project.project_name + '</span>' +
      hidden_field( variable, attribute )
    end
  end

  def select_for_taskusers(variable, attribute, options, html_options)
    insobj = instance_variable_get("@#{variable}")
    if insobj == nil
      select( variable, attribute,
              {},
              options, html_options)
    end
  end

  def list_for_taskusers(task_id)
    choises = Array.new
    if task_id.nil?
      choises = choises
    else
      users = DatTaskuser.find(:all,
                                  :conditions=>["task_id = ?", task_id],
                                  :include=>[{:dat_projectuser=>:user}])
      choises = users.map{
                            |u| [(u.dat_projectuser.user.nil? ? u.dat_projectuser.email : u.dat_projectuser.user.sap_name), u.projectuser_id]
                          }
    end

    return choises
  end
  
  def object_for_taskusers(task_id)
    objects = Array.new
    if task_id.nil?
      objects = objects
    else
      users = DatTaskuser.find(:all,
                                  :conditions=>["task_id = ?", task_id],
                                  :include=>[{:dat_projectuser=>:user}])
      objects = users.map{
                            |u| {:user_name=>(u.dat_projectuser.nil? ? '' : (u.dat_projectuser.user.nil? ? u.dat_projectuser.email : u.dat_projectuser.user.sap_name) ), :projectuser_id=>u.projectuser_id}
                          }
    end

    return objects
  end
end
