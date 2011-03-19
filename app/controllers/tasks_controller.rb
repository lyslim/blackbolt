class TasksController < ApplicationController

  include ProjectsHelper
  include TasksHelper

  def new
    respond_to do |f|
      f.html { render :partial => 'dialog_new' }
      f.json { render :json => new_item }
    end
  end

  def show
    dlg_edit
  end

  def new_item
    @task = DatTask.new

    projectuser = DatProjectuser.find_by_user_id(current_user.id)
    @task.client_user_id = projectuser.id

    @projectcomp = DatProjectcomp.new(params[:dlg_tsk_edit_comp])
    @projectcomp.task_kbn = "1" ;

    projectusers = object_for_projectusers(@current_project.id)

    taskusers = object_for_taskusers(@task.id)

    #-----------------------------
    # JSON
    #-----------------------------
    result  = {
      :task           => @task.attributes,
      :projectcomp    => @projectcomp.attributes,
      :projectusers   => projectusers,
      :taskusers      => taskusers
    }
    result = result_for_json(true, '', result)
  end

  def dlg_edit
    comp_id = params[:id]

    if comp_id.nil? || comp_id == ""
      #-----------------------------
      # JSON
      #-----------------------------
      result  = {
        :task           => @task.attributes,
        :projectcomp    => @projectcomp.attributes,
        :projectusers   => projectusers,
        :taskusers      => taskusers
      }

      render :text => result_for_json(true, '', result)
      return
    end

    return unless my_item?(comp_id)# check permission

    @projectcomp = DatProjectcomp.find(:first,
                          :conditions => [" dat_projectcomps.id = ? ", comp_id],
                          :include =>[:dat_project, :dat_task] )
    @task = @projectcomp.dat_task

    projectusers = object_for_projectusers(@current_project.id)

    taskusers = object_for_taskusers(@task.id)

    #-----------------------------
    # JSON
    #-----------------------------
    result  = {
      :task           => @task.attributes,
      :projectcomp    => @projectcomp.attributes,
      :projectusers   => projectusers,
      :taskusers      => taskusers
    }

    render :text => result_for_json(true, '', result)
  end

  def create
    session_user_id = current_user.id

    params[:dlg_tsk_edit_comp].delete('id')
    params[:dlg_tsk_edit_task].delete('id')

    @projectcomp = DatProjectcomp.new(params[:dlg_tsk_edit_comp])
    @projectcomp.task_kbn = "1" ;
    @projectcomp.create_user_id = session_user_id
    @projectcomp.update_user_id = session_user_id
    @projectcomp.last_operation_kbn = 2

    max_line_no = DatProjectcomp.maximum( :line_no,
                                          :conditions=>["project_id = ? ", @projectcomp.project_id]
                                        )
    max_line_no = 0 if max_line_no.nil?
    @projectcomp.line_no = max_line_no + 1

    if !@projectcomp.save
      message = "Error in creating project component."
      render :text => result_for_json(false, message, {})
      return
    end

    @task = DatTask.new(params[:dlg_tsk_edit_task])
    @task.create_user_id = session_user_id
    @task.update_user_id = session_user_id
    @task.last_operation_kbn = 2
    @task.project_tree_id = @projectcomp.id

    if ! params[:dlg_tsk_edit_taskusers].nil?
      for puser in params[:dlg_tsk_edit_taskusers][:projectuser_id]

        taskuser = @task.dat_taskusers.build(:projectuser_id=>puser)
        taskuser.create_user_id = session_user_id
      end
    end
    if !@task.save
      message = "Error in creating task."
      render :text => result_for_json(false, message, {})
      return
    end

    respond_to do |f|
      f.html { redirect_to :action => index }
      f.json { render :text => result_for_json(true, '', {})}
    end
  end

  def update
    session_user_id = current_user.id

    return unless my_item?(params[:dlg_tsk_edit_comp][:id])# check permission

    #-----------------------------
    # Get registered object
    #-----------------------------
    @projectcomp = DatProjectcomp.find(:first,
                          :conditions => [" dat_projectcomps.id = ? ", params[:dlg_tsk_edit_comp][:id]],
                          :include =>[{:dat_task=>[:dat_taskusers]}] )
    @projectcomp.update_user_id = session_user_id
    @projectcomp.last_operation_kbn = 3
    @task = @projectcomp.dat_task
    @task.update_user_id = session_user_id
    @task.last_operation_kbn = 3

    #-----------------------------
    # task user generation
    #-----------------------------
    @task.dat_taskusers.clear  
    if ! params[:dlg_tsk_edit_taskusers].nil?
      for puser in params[:dlg_tsk_edit_taskusers][:projectuser_id]
        taskuser = @task.dat_taskusers.build(:projectuser_id=>puser)
        taskuser.create_user_id = session_user_id
      end
    end

    if ! @projectcomp.update_attributes(params[:dlg_tsk_edit_comp])
      message = "Error in updating project component."
      render :text => result_for_json(false, message, {})
      return
    end

    if ! @task.update_attributes(params[:dlg_tsk_edit_task])
      message = "Error in updating task component."
      render :text => result_for_json(false, message, {})
      return
    end

    respond_to do |f|
      f.html { redirect_to :action => index }
      f.json { render :text => result_for_json(true, '', {})}
    end

  end

  def destroy
    return unless my_item?(params[:id])# check permission

    projectcomp = DatProjectcomp.find(params[:id])
    if ! projectcomp.destroy
      message = "Error in deleting task."
      render :text => result_for_json(false, message, {})
      return
    end

    respond_to do |f|
      f.html { redirect_to :action => index }
      f.json { render :text => result_for_json(true, '', {})}
    end
  end
end
