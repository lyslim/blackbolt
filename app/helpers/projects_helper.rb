module ProjectsHelper

  include ERB::Util

  def link_project_name(project, options="")
    to = {:controller=>:project, :action=>:index, :id=>project.id}
    link_to(disp_project_name(project)+options.to_s, to)
  end

  def disp_project_name(project)
    project.project_name.empty? ? '&nbsp;' : h(project.project_name)
  end

  def disp_end_user_name(project)
    project.end_user_name.empty? ? '&nbsp;' : h(project.end_user_name)
  end

  def disp_project_name_by_comp(projectcomp)
    ret = projectcomp.dat_project.nil? ? '&nbsp;' : projectcomp.dat_project.project_name
  end

  def disp_task_id(projectcomp)
    ret = ""

    case projectcomp.task_kbn
    when 1
      task = projectcomp.dat_task
      ret = task.task_cd.nil? ? '&nbsp;' : '(' + task.task_cd + ')'
    else
      ret = '&nbsp;'
    end
  end

  def disp_detail_name(projectcomp)
    ret = ""
    ret = projectcomp.item_name.nil? ? '&nbsp;' : h(projectcomp.item_name)

    if projectcomp.task_kbn == 3
      event = projectcomp.dat_event
      time = ""
      if event.start_time.nil? && event.end_time.nil?
      else
        s_date = ""
        s_time = ""
        e_date = ""
        e_time = ""
       if ! event.start_time.nil?
          s_date = fmt_time( event.start_date, :Y2MD ).to_s
          s_time = fmt_time( event.start_time, :HM ).to_s
        end
        if ! event.end_time.nil?
          e_date = fmt_time( event.end_date, :Y2MD ).to_s
          e_time = fmt_time( event.end_time, :HM ).to_s
        end
        if s_date != ""
          if s_date != e_date
            time = "(" + s_date + "&nbsp;" + s_time + "&nbsp;～&nbsp;" + e_date + "&nbsp;" + e_time + ")"
          else
            time = "(" + s_date + "&nbsp;" + s_time + "&nbsp;～&nbsp;" + e_time + ")"
          end
        elsif e_date != ""
          if s_date != e_date
            time = "(" + s_date + "&nbsp;" + s_time + "&nbsp;～&nbsp;" + e_date + "&nbsp;" + e_time + ")"
          else
            time = "(" + e_date + "&nbsp;" + s_time + "&nbsp;～&nbsp;" + e_time + ")"
          end
        end
      end
      ret += "&nbsp;" + time
    end

    return ret
  end

  def disp_kbn_icon(projectcomp)
    ret = ""
    ret = case projectcomp.task_kbn
      when 1 then '&nbsp;'
      when 2 then image_tag("/images/icon_milestone.gif", {:border => 0, :align=>"absmiddle"})
      when 3 then image_tag("/images/icon_event.gif", {:border => 0, :align=>"absmiddle"})
      else '&nbsp;'
    end
  end

  def disp_progress_icon(projectcomp)
    ret = ""
    case projectcomp.task_kbn
    when 1
      task = projectcomp.dat_task
      if task.progress_kbn == 3
        ret = image_tag("/images/icon_complete.gif", {:border => 0, :align=>"absmiddle"})
      else
        ret = '&nbsp;'
      end
    else
      ret = '&nbsp;'
    end
  end

  def disp_create_user_name(projectcomp)
    ret = ""
    case projectcomp.task_kbn
    when 1,2,3
      if projectcomp.mst_user_create.nil?
        return '&nbsp;'
      else
        '(' + h(projectcomp.mst_user_create.sap_name) + ')'
      end
    else
      ret = '&nbsp;'
    end
  end

  def disp_client_user_name(projectcomp)
    ret = ""
    case projectcomp.task_kbn
    when 1
      task = projectcomp.dat_task
      return '&nbsp;' if task.dat_user_client.nil?

      if task.dat_user_client.user.nil?
        return '(' + h(task.dat_user_client.email) + ')'
      else
        return '(' + h(task.dat_user_client.user.sap_name) + ')'
      end
    when 2,3
      if projectcomp.mst_user_create.nil?
        return '&nbsp;'
      else
        return '(' + h(projectcomp.mst_user_create.sap_name) + ')'
      end
    else
      return '&nbsp;'
    end
  end

  def disp_charge_user_name(projectcomp)
    ret = ""
    case projectcomp.task_kbn
    when 1
      # Tasks
      puser = projectcomp.dat_task.dat_user_main
      if puser.nil?
        ret = '&nbsp;'
      else
        user = puser.user
        ret = h(user.nil? ? puser.email : user.sap_name)
      end
    else
      # Categories, milestones, events, etc.
      ret = '&nbsp;'
    end
  end

  def disp_priority(projectcomp)
    ret = ""
    case projectcomp.task_kbn
    when 1
      task = projectcomp.dat_task
      case task.priority_kbn
      when 1
        if task.progress_kbn == 3
          ret = image_tag("/images/icon/priority_low_complete.gif", {:alt=>app_localized_message(:label, :icon_priority_low), :border => 0, :align=>"absmiddle"})
        else
          ret = image_tag("/images/icon/priority_low.gif", {:alt=>app_localized_message(:label, :icon_priority_low), :border => 0, :align=>"absmiddle"})
        end
      when 2
        ret = '&nbsp;'
      when 3
        if task.progress_kbn == 3
          ret = image_tag("/images/icon/priority_high_complete.gif", {:alt=>app_localized_message(:label, :icon_priority_high), :border => 0, :align=>"absmiddle"})
        else
          ret = image_tag("/images/icon/priority_high.gif", {:alt=>app_localized_message(:label, :icon_priority_high), :border => 0, :align=>"absmiddle"})
        end
      else
        ret = '&nbsp;'
      end
    else
      ret = '&nbsp;'
    end
  end

  def disp_delivery_date(projectcomp)
    ret = ""
    case projectcomp.task_kbn
    when 1
      task =   projectcomp.dat_task
      ret  = task.nil? ? '&nbsp;' : fmt_time(task.complete_date, :Y2MD)
    when 2
      milestone = projectcomp.dat_milestone
      ret  = milestone.nil? ? '&nbsp;' : fmt_time(milestone.mils_date, :Y2MD)
    when 3
      event = projectcomp.dat_event
      ret   = event.nil? ? '&nbsp;' : fmt_time(event.end_date, :Y2MD)
    else
      ret = '&nbsp;'
    end
  end

  def disp_comp_exp_date(projectcomp)
    ret = ""
    case projectcomp.task_kbn
    when 1
      task = projectcomp.dat_task
      ret  = task.nil? ? '&nbsp;' : fmt_time(task.complete_date, :Y2MD)
    when 2
      milestone = projectcomp.dat_milestone
      ret  = milestone.nil? ? '&nbsp;' : fmt_time(milestone.mils_date, :Y2MD)
    when 3
      event = projectcomp.dat_event
      ret = event.nil? ? '&nbsp;' : fmt_time(event.end_date, :Y2MD)
    else
      ret = '&nbsp;'
    end
  end


  def disp_situation(projectcomp)
    ret = ""
    case projectcomp.task_kbn
    when 1
      task = projectcomp.dat_task
      ret = case task.progress_kbn
        when 0 then ret = '&nbsp;'
        when 1 then app_localized_message( :label, "progress_rate_" + task.progress_kbn.to_s )
        when 2 then app_localized_message( :label, :progress_kbn_2 )
        when 3 then app_localized_message( :label, :progress_kbn_3 )
        when 9 then app_localized_message( :label, :progress_kbn_9 )
        else '&nbsp;'
      end
    else
      ret = '&nbsp;'
    end
  end

  def disp_task_color(projectcomp)
    ret = ""
    case projectcomp.task_kbn
    when 1
      task = projectcomp.dat_task
      if task
        ret = (task.progress_kbn == 3) ? '#cccccc' : '#000000'
      end
    else
      ret = '#000000'
    end
      
  end

  def disp_task_count(project)
    projectcomps = project.dat_projectcomps

    allcount = projectcomps.size

    completecount = 0
    now = Time.now
    dnow = Date.today
    projectcomps.each do | projectcomp |
      case projectcomp.task_kbn
      when 1
        completecount += 1 if projectcomp.dat_task.progress_kbn == 3
      when 2
        if ! projectcomp.dat_milestone.mils_date.nil?
          completecount += 1 if projectcomp.dat_milestone.mils_date < dnow
        end
      when 3
        if ! ( projectcomp.dat_event.start_date.nil? || projectcomp.dat_event.start_time.nil? )
          completecount += 1 if projectcomp.dat_event.start_date < dnow || 
                                (projectcomp.dat_event.start_date == dnow && projectcomp.dat_event.start_time.strftime('%H%M').to_i < now.strftime('%H%M').to_i)
        end
      else
      end
    end

    return completecount.to_s + "/" + allcount.to_s
  end

  def disp_today_icon( projectcomp )
    ret = ""
    case projectcomp.task_kbn
    when 1
      task = projectcomp.dat_task
      if (task)
        ret = (task.complete_date == Date.today) ? image_tag("icon/today.gif", {:alt=>app_localized_message( :label, :icon_today ) , :border => 0, :align=>"absmiddle"}) : '&nbsp;'
      end
    else
      ret = '&nbsp;'
    end
  end

  def disp_date_range( project )
    if project.start_date.nil? && project.delivery_date.nil?
      '&nbsp;'
    else
      fmt_time(project.start_date, :Y2MD) + '～' + fmt_time(project.delivery_date, :Y2MD)
    end
  end

  def disp_projectuser_name( pu )
    pu.user.nil? ? pu.email : pu.user.sap_name
  end

  def disp_projectuser_skype_icon(project_user)
    if !project_user.user.nil? and (!project_user.user.skype_id.nil? and project_user.user.skype_id != '')
      tag = '<a href="skype:' + project_user.user.skype_id + '?chat" onclick="return skypeCheck();">'
      tag << image_tag('http://mystatus.skype.com/smallicon/' + project_user.user.skype_id , :style=>"border: 0px;", :alt=>app_localized_message( :label, :skype_status))
      tag << '</a>'
    else
      tag = '&nbsp;'
    end
    tag
  end

  def select_for_users(variable, attribute, project_id, options = {}, html_options = {})
    choises = Array.new
    unless project_id.nil?
      opt = {
        :conditions => ["project_id = ?", project_id],
        :include    => :user
      }
      users = DatProjectuser.find(:all, opt)
      choises = users.map do |u|
        [(u.user.nil? ? u.email : u.user.sap_name), u.id]
      end
      if options[:include_all]
        choises.insert(0, [app_localized_message(:label, :all_member) ,""])
      end
    else
      choises = choises
    end
    select(variable, attribute, choises, options, html_options)
  end

  def select_for_users_tag(name, project_id, options = {})

    choises = Array.new
    unless project_id.nil?
      opt = {
        :conditions => ["project_id = ?", project_id],
        :include    => :user
      }
      users = DatProjectuser.find(:all, opt)
      choises = users.map do |u|
        [(u.user.nil? ? u.email : u.user.sap_name), u.id]
      end
      if options[:include_all]
        choises.insert(0, [ app_localized_message(:label, :all_member) ,""])
      end
    else
      choises = choises
    end
    select_tag(name, options_for_select(choises), options)
  end

  def list_for_projectusers(project_id)
    choises = Array.new
    unless project_id.nil?
      opt = {
        :conditions => ["project_id = ?", project_id],
        :include    => :user
      }
      users = DatProjectuser.find(:all, opt)
      choises = users.map do |u|
        [(u.user.nil? ? u.email : u.user.sap_name), u.id]
      end
    else
      choises = choises
    end
    return choises
  end

  def object_for_projectusers(project_id)
    objects = Array.new
    unless project_id.nil?
      opt = {
        :conditions => ["project_id = ?", project_id],
        :include    => :user
      }
      users = DatProjectuser.find(:all, opt)
      objects = users.map do |u|
        {:user_name => h(u.user.nil? ? u.email : u.user.sap_name), :projectuser_id => u.id}
      end
    else
      choises = choises
    end
    return objects
  end

  def disp_projectusers(project)
    ret = ""
    project.dat_projectusers.each do |pu|
      ret += ', ' if ret != ""
      ret += h(pu.user.nil? ? pu.email : pu.user.sap_name)
    end
    
    return ret
  end

  def select_task_kbn_tag()
    tasks = <<TASKS
<option value="">#{app_localized_message(:label, :all)}</option>
<option value="1">#{app_localized_message(:label, :task)}</option>
<option value="2">#{app_localized_message(:label, :milestone)}</option>
<option value="3">#{app_localized_message(:label, :event)}</option>
TASKS
    tag = select_tag(:calendar_filter_task_kbn, tasks, {:style=>'width:120px;'})
  end

  def disp_projectlog_information(log)
    task_key = case log.dat_projectcomp.task_kbn
               when 1 then :task#app_localized_message(:label, :task)
               when 2 then :milestone#app_localized_message(:label, :milestone)
               when 3 then :event#app_localized_message(:label, :event)
               end
    task_kbn = app_localized_message(:label, task_key)
    
    user_name   = disp_charge_user_name(log.dat_projectcomp)
    detail_name = disp_detail_name(log.dat_projectcomp)
    user_name   = "" if user_name == "&nbsp;"
    detail_name = "" if detail_name == "&nbsp;"
    
    message = app_localized_message(:label, "log_kbn_" + log.log_kbn.to_s)
    message = sprintf(message, user_name, detail_name, task_kbn)
    message = message.strip
    message
  end
end
