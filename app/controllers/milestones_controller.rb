class MilestonesController < ApplicationController

  include ProjectsHelper
  include MilestonesHelper

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

    @miles = DatTask.new

    @projectcomp = DatProjectcomp.new(params[:dlg_mil_edit_comp])
    @projectcomp.task_kbn = "2" ;

    #-----------------------------
    # JSON
    #-----------------------------
    result  = {
      :miles           => @miles.attributes,
      :projectcomp    => @projectcomp.attributes
    }
    result
  end

  def dlg_edit
    comp_id = params[:id]

    if comp_id.nil? || comp_id == ""
      #-----------------------------
      # if ID is not specified, redirect to new dialog
      #-----------------------------
      redirect_to :action => 'dlg_new'
      return
    end

    return unless my_item?(comp_id)# check permission

    @projectcomp = DatProjectcomp.find(:first,
                          :conditions => [" dat_projectcomps.id = ? ", comp_id],
                          :include =>:dat_milestone )
    @miles = @projectcomp.dat_milestone

    #-----------------------------
    # JSON
    #-----------------------------
    result  = {
      :miles           => @miles.attributes,
      :projectcomp    => @projectcomp.attributes
    }

    render :text => result_for_json(true, '', result)

  end

  def create
    session_user_id = @current_user.id

    @projectcomp = DatProjectcomp.new(params[:dlg_mil_edit_comp])
    @projectcomp.task_kbn = "2" ;
    @projectcomp.create_user_id = session_user_id
    @projectcomp.update_user_id = session_user_id
    @projectcomp.last_operation_kbn = 2

    @miles = DatMilestone.new( params[:dlg_mil_edit_miles] )
    @miles.create_user_id = session_user_id
    @miles.update_user_id = session_user_id
    @miles.last_operation_kbn = 2
    @projectcomp.dat_milestone = @miles

    max_line_no = DatProjectcomp.maximum( :line_no,
                                          :conditions=>["project_id = ? ", @projectcomp.project_id]
                                        )
    max_line_no = 0 if max_line_no.nil?
    @projectcomp.line_no = max_line_no + 1

    if ! @projectcomp.save
      message = "Error in creating Milestone."
      render :text => result_for_json(false, message, {})
      return
    end

    respond_to do |f|
      f.html { redirect_to :action => index }
      f.json { render :text => result_for_json(true, '', {})}
    end
  end

  def update
    session_user_id = @current_user.id

    return unless my_item?(params[:dlg_mil_edit_comp][:id])# check permission

    @projectcomp = DatProjectcomp.find(:first,
                          :conditions => [" dat_projectcomps.id = ? ", params[:dlg_mil_edit_comp][:id]],
                          :include =>:dat_milestone )
    @projectcomp.update_user_id = session_user_id
    @projectcomp.last_operation_kbn = 3
    @miles = @projectcomp.dat_milestone
    @miles.update_user_id = session_user_id
    @miles.last_operation_kbn = 3

    if ! @projectcomp.update_attributes(params[:dlg_mil_edit_comp])
      message = "Error in updating project component."
      render :text => result_for_json(false, message, {})
      return
    end

    if ! @miles.update_attributes(params[:dlg_mil_edit_miles])
      message = "Error in updating milestone."
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
      message = "Error in deleting milestone."
      render :text => result_for_json(false, message, {})
      return
    end

    respond_to do |f|
      f.html { redirect_to :action => index }
      f.json { render :text => result_for_json(true, '', {})}
    end
  end

end
