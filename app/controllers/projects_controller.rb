class ProjectsController < ApplicationController
  
  before_filter :authenticate_user!
  
  include ProjectsHelper
  include TasksHelper

  def index
    
    unless DatProjectuser.nil?
       datProjUser = DatProjectuser.find_by_email(current_user.email)
       unless datProjUser.nil?
         if datProjUser.user_id.nil?
            datProjUser.update_attribute('user_id', current_user.id)
         end
       end
    end
    
    opt = {
     :include    => [{:dat_projectusers=>:user}],
     :conditions => ["dat_projects.valid_flg = 1 AND dat_projects.id in (SELECT pu.project_id FROM dat_projectusers pu WHERE pu.user_id = ? ) ", @current_user.id],
     :order      => "dat_projects.start_date desc, delivery_date desc"
    }
    @projects = DatProject.find(:all, opt)
    @active_project_ids = @active_projects.map {|p| p.id}

    if params[:id] && params[:active_flg]

    	project      = DatProject.find_project_and_users(params[:id],@current_user.id)
	    projectusers = project.dat_projectusers[0]
	    projectusers.update_attribute(:active_flg, params[:active_flg])

	    # JSON
	    result  = {
	      :project_id   => project.id,
	      :project_name => project.project_name,
	      :active_flg   => projectusers.active_flg
	    }
		render :json => result_for_json(true, '', result)
    end

  end

  def new
    @project = DatProject.new
    @project.dat_projectusers.build

    @templates = MstTemplate.find(:all)
    
    render :action => "edit"
  end

  def show
    if @active_projects.blank?
      redirect_to :action => 'new'
    else
      @projects = @active_projects
      @project  = @current_project
    end

    @tasks         = get_tasks()
    @events        = get_events()
    @projectlogs   = get_projectlogs()
    @projectusers  = get_projectusers()

  end

  def edit

    unless params[:id].nil?
      p_cd = params[:id]
      opt = {
        :conditions => [" dat_projects.project_cd=? ", p_cd],
        :include    => :dat_projectusers
      }
      @project = DatProject.find(:first, opt)

      @project.dat_projectusers.build if @project.dat_projectusers.size == 0
      
      @templates = MstTemplate.find(:all)
    else
      redirect_to :action => 'new'
    end
  end
  
  # create project based on user registered
  # invite user to project if specified
  # invite user unregistered to sign up if specified
  def create
    project = DatProject.new(params[:project])
    project.create_user_id = current_user.id
    project.update_user_id = current_user.id

    if ! current_user.id.nil?
      user = User.find(current_user.id)
      projectuser = project.dat_projectusers.build()
      projectuser.email = user.email
      projectuser.user_id = user.id
      projectuser.create_user_id = project.create_user_id
    end
    
    for user in params[:users]
      next if user.empty?
      next if user == current_user.email
      
      projectuser = project.dat_projectusers.build(:email=>user)
      projectuser.create_user_id = project.create_user_id
      if usr = User.find_by_email(user)

        projectuser.user_id = usr.id


        if ! usr.email.nil? && ! usr.email.empty?
          AppMailer.deliver_mail_invite_project( usr, {:subject=>app_localized_message( :label, :invite_project_mail_subject ), :project_name=>params[:project][:project_name], :url_login=>project_url(:id=>params[:project][:project_cd])} )
        end
      else

        if ! projectuser.email.nil? && ! projectuser.email.empty?
          AppMailer.deliver_mail_invite( projectuser, {:subject=>app_localized_message( :label, :invite_mail_subject ), :url_signup=>new_user_registration_url} )
        end
      end
    end
  
    if ! params[:template][:id].nil? && ! params[:template][:id].empty?

      template = MstTemplate.find(:first,
                                  :conditions=>[" mst_templates.id=? ", params[:template][:id]], 
                                  :include=>[{:mst_compositions=>[:mst_tptask, :mst_tpmilestone, :mst_tpevent]}])

        project.copyFromTemplate(template)
    end

    if ! project.save
      @project = project 
      @templates = MstTemplate.find(:all)
      render :action => 'edit'
      return 
    end

    path = get_project_files_root(project.id)
    #Dir.mkdir(path)
    FileUtils.mkdir_p(path)

    redirect_to :action => 'index'
  end

  def update
    if params[:project][:id].nil? || params[:project][:id].empty?
      # ????? error-handling ????? 
    else

      id = params[:project][:id]
      project = DatProject.find(:first,
                                :conditions=>[" dat_projects.id=? ", id],
                                :include=>:dat_projectusers)

      project.update_user_id = current_user.id

      projectusers = Array.new
      project.dat_projectusers.each do |puser|
        projectusers.push puser.email
      end

      for user in params[:users]
        next if user.empty?
        next if ! projectusers.delete(user).nil?
        next if user == current_user.email

        projectuser = project.dat_projectusers.build(:email=>user)
        projectuser.create_user_id = project.update_user_id
        if mstusr = User.find_by_email(user)

          projectuser.user_id = mstusr.id

          if ! mstusr.email.nil? && ! mstusr.email.empty?
            AppMailer.deliver_mail_invite_project( mstusr, {:subject=>app_localized_message( :label, :invite_project_mail_subject ), :project_name=>params[:project][:project_name], :url_login=>project_url} )
          end
        else

          if ! projectuser.email.nil? && ! projectuser.email.empty?
            AppMailer.deliver_mail_invite( projectuser, {:subject=>app_localized_message( :label, :invite_mail_subject ), :url_signup=>new_user_registration_url} )
          end
        end
      end


      if ! project.update_attributes(params[:project])
        # ????? error-handling ????? 
        @project = project 
        @templates = MstTemplate.find(:all)
        render :action => 'edit'
        return 
      end
      
      if projectusers.size > 0
        conditions = " project_id = ? AND email in (__emails__)"
        emails   = []
        prepared = ''
        projectusers.each_with_index do |email, index|
          logger.debug email
          emails   << email
          prepared << ((index > 0) ? ',' : '') + '?'
        end
        conditions = [conditions.gsub(/__emails__/, prepared), project.id] + emails
        DatProjectuser.destroy_all( conditions )
      end
    end

    redirect_to :action => 'index'
  end

  def destroy
    if params[:project][:id].nil? || params[:project][:id].empty?
    elsif my_project?(params[:project][:id])

      id = params[:project][:id]
      if ! DatProject.destroy(id)
        # ????? error handling ????? 
        @project = project 
        @templates = MstTemplate.find(:all)
        render :action => 'edit'
        return 
      end
    else
      render :text => 'Permission Denied'
      return
    end

    redirect_to :action => 'index'
  end

  def wbs
    respond_to do |f|
      f.html # render wbs.html.erb
      f.json { render :json => json_for_wbs() }
    end
  end

  def gantt
    respond_to do |f|
      f.html # render gantt.html.erb
      f.json { render :json => json_for_gantt() }
    end
  end

  def calendar
    p = @current_project
    @calendar = init_calendar(p.start_date, p.delivery_date)
    respond_to do |f|
      f.html # render calendar.html.erb
      f.json { render :json => json_for_calendar }
    end
  end

  def get_tasks

    conditions = "dat_projects.valid_flg = 1 AND dat_projectusers.user_id = #{current_user.id}"
    if ! @project.id.nil?
      conditions += " AND dat_projectcomps.project_id = #{@project.id}"
    end
    
    opt = {
      :conditions => conditions,
      :include    => [{:dat_taskusers=>:dat_projectuser}, {:dat_projectcomp=>:dat_project}], 
      :order      => "dat_tasks.id desc"
    }
    DatTask.find(:all, opt)
  end

  def get_events
    conditions = "dat_projectusers.user_id = #{current_user.id}"
    if ! @project.id.nil?
      conditions += " AND dat_projectcomps.project_id = #{@project.id}"
    else
      conditions += " AND dat_projectcomps.project_id = 0 "
    end
    opt = {
      :conditions => conditions,
      :include    => [{:dat_eventusers=>:dat_projectuser}, {:dat_projectcomp=>:dat_project}], 
      :order      => "dat_events.start_date desc, dat_events.start_time desc",
      :limit      => 5
    }
    DatEvent.find(:all, opt)
  end

  def get_projectlogs
    limit_date = (Date.today - 7).strftime('%Y-%m-%d')
    conditions_sql = "dat_projects.valid_flg = 1 AND dat_projectlogs.created_on >= '#{limit_date}'"
    conditions_sql << " AND dat_projectcomps.project_id = ?"
    
    conditions = [conditions_sql]
    conditions << ((@project.id.nil?) ? '0' : @project.id.to_s)
    
    opt = {
      :conditions => conditions,
      :include    => [{:dat_projectcomp=>:dat_project}],
      :order      => "dat_projectlogs.created_on desc"
    }
    DatProjectlog.find(:all, opt)
  end

  def get_projectusers
    conditions = " dat_projects.valid_flg = 1 "
    conditions << " AND dat_projects.id = "
    conditions << ((@project.id.nil?) ? '0' : @project.id.to_s)

    opt = {
      :conditions => conditions,
      :include    => [:dat_project, :user ], 
      :order      => "dat_projectusers.id "
    }
    DatProjectuser.find(:all, opt)
  end

  private

  def json_for_wbs
    project = get_project_detail(@current_project.id)

    json_items = project.dat_projectcomps.map do |pc|
        {
          :task_kbn           => pc.task_kbn,
          :task_cd            => disp_task_id( pc ),
          :item_name          => disp_detail_name( pc ),
          :user_name          => disp_charge_user_name( pc ),
          :comp_exp_date      => disp_comp_exp_date( pc ),
          :situation          => disp_situation( pc ),
          :priority_kbn       => pc.task_kbn==1 ? pc.dat_task.priority_kbn : "",
          :progress_kbn       => pc.task_kbn==1 ? pc.dat_task.progress_kbn : "",
          :create_user_name   => disp_create_user_name( pc ),
          :client_user_name   => disp_client_user_name( pc ),
          :id                 => pc.id,
          :class_word1        => pc.class_word1,
          :class_word2        => pc.class_word2,
          :class_word3        => pc.class_word3
        }
    end

    json = {
      :items      => json_items,
      :totalCount => json_items.size
    }

  end

  def json_for_gantt
    project = get_project_detail(@current_project.id)

    json_items = project.dat_projectcomps.map do |pc|
        {
          :task_kbn            => pc.task_kbn,
          :task_cd             => disp_task_id( pc ),
          :item_name           => disp_detail_name( pc ),
          :user_name           => disp_charge_user_name( pc ),
          :comp_exp_date       => disp_comp_exp_date( pc ),
          :situation           => disp_situation( pc ),
          :priority_kbn        => pc.task_kbn==1 ? pc.dat_task.priority_kbn : "",
          :progress_kbn        => pc.task_kbn==1 ? pc.dat_task.progress_kbn : "",
          :start_date          => pc.task_kbn==1 ? pc.dat_task.start_date : ( pc.task_kbn==2 ? pc.dat_milestone.mils_date : ( pc.task_kbn==3 ? pc.dat_event.start_date : "" ) ),
          :end_date            => pc.task_kbn==1 ? pc.dat_task.end_date : ( pc.task_kbn==2 ? pc.dat_milestone.mils_date : ( pc.task_kbn==3 ? pc.dat_event.start_date : "" ) ),
          :create_user_name    => disp_create_user_name( pc ),
          :client_user_name    => disp_client_user_name( pc ),
          :id                  => pc.id,
          :class_word1         => pc.class_word1,
          :class_word2         => pc.class_word2,
          :class_word3         => pc.class_word3
        }
    end
    json = {
      :project => project,
      :items      => json_items,
      :totalCount => json_items.size
    }

    json = result_for_json(true, '', json)

  end


  def json_for_calendar
    project = get_project_detail2(@current_project.id)
    json_items = []
    if project
      project.dat_projectcomps.map do |pc|
        def_params = pc.attributes
        start_date, end_date = pc.get_dates
        if start_date
          date_format = '%Y-%m-%d'
          add_params = {
            :kbn => pc.taskkbn,
            :start_date => start_date ? start_date.strftime(date_format) : nil,
            :end_date   => end_date ? end_date.strftime(date_format) : nil,
          }
          json_item = def_params.merge(add_params)
          json_items.push(json_item)
        end
      end
      # sort
      # json_items.sort {|a, b| a['task_kbn'] <=> b['task_kbn'] }
    end
    logger.debug json_items.inspect
    json = {
      :project    => project.attributes,
      :items      => json_items,
      :totalCount => json_items.size,
    }
  end


  def get_project_detail(id)
    if id.nil?

      project = DatProject.new
    else

      include = [ {:dat_projectcomps=>[:dat_milestone, {:dat_task=>[{:dat_user_main=>:user}, {:dat_user_client=>:user}]}, :dat_event, :mst_user_create]} ]
      project = DatProject.find( :first,
                                 :conditions => [" dat_projects.id=? ", id],
                                 :include    => include,
                                 :order      => "dat_projectcomps.line_no asc"
                               )
    end

    project
  end

  def get_project_detail2(id)
    if id.nil?

      project = DatProject.new
    else

      include = [ {:dat_projectcomps=>[:dat_milestone, {:dat_task=>[{:dat_user_main=>:user}, {:dat_user_client=>:user}]}, :dat_event, :mst_user_create]} ]
      project = DatProject.find( :first,
                                 :conditions => [" dat_projects.id=? ", id],
                                 :include    => include,
                                 :order      => "dat_projectcomps.task_kbn asc, dat_tasks.start_date, dat_tasks.end_date desc"
                               )
    end
    project
  end
end
