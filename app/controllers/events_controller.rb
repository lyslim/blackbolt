class EventsController < ApplicationController

  include ProjectsHelper
  include EventsHelper

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
    @event = DatEvent.new

    @projectcomp = DatProjectcomp.new(params[:dlg_evt_edit_comp])
    @projectcomp.task_kbn = "3" ;

    projectusers = object_for_projectusers(@current_project.id)
    eventusers = object_for_eventusers(@event.id)

    #-----------------------------
    # JSON
    #-----------------------------
    result  = {
      :event          => @event.attributes,
      :projectcomp    => @projectcomp.attributes,
      :projectusers   => projectusers,
      :eventusers     => eventusers
    }
    result = result_for_json(true, '', result)
  end

  def dlg_edit
    comp_id = params[:id]

    if comp_id.nil? || comp_id == ""
      redirect_to :action => 'dlg_new'
      return
    end

    return unless my_item?(comp_id)# check permission

    @projectcomp = DatProjectcomp.find(:first,
                          :conditions => [" dat_projectcomps.id = ? ", comp_id],
                          :include =>[:dat_project, :dat_event] )
    @event = @projectcomp.dat_event

    projectusers = object_for_projectusers(@current_project.id)

    eventusers = object_for_eventusers(@event.id)

    #-----------------------------
    # JSON
    #-----------------------------
    event_att = @event.attributes
    event_att['start_time'] = event_att['start_time'] ? event_att['start_time'].strftime('%H:%M:%S') : ''
    event_att['end_time'] = event_att['end_time'] ? event_att['end_time'].strftime('%H:%M:%S') : ''

    result  = {
      :event          => event_att,
      :projectcomp    => @projectcomp.attributes,
      :projectusers   => projectusers,
      :eventusers     => eventusers
    }

    render :text => result_for_json(true, '', result)

  end

  def create
    session_user_id = @current_user.id

    @projectcomp = DatProjectcomp.new(params[:dlg_evt_edit_comp])
    @projectcomp.task_kbn = "3" ;
    @projectcomp.create_user_id = session_user_id
    @projectcomp.update_user_id = session_user_id
    @projectcomp.last_operation_kbn = 2

    @event = DatEvent.new( params[:dlg_evt_edit_event] )
    @event.create_user_id = session_user_id
    @event.update_user_id = session_user_id
    @event.last_operation_kbn = 2
    @projectcomp.dat_event = @event

    #-----------------------------
    # Additional position (line number) determined
    #-----------------------------
    max_line_no = DatProjectcomp.maximum( :line_no,
                                          :conditions=>["project_id = ? ", @projectcomp.project_id]
                                        )
    max_line_no = 0 if max_line_no.nil?
    @projectcomp.line_no = max_line_no + 1

    if ! params[:dlg_evt_edit_eventusers].nil?
      for puser in params[:dlg_evt_edit_eventusers][:projectuser_id]
        # buildにて生成し、ここでは保存しない
        eventuser = @event.dat_eventusers.build(:projectuser_id=>puser)
        eventuser.create_user_id = session_user_id
      end
    end

    if ! @projectcomp.save
      message = "Error in saving project component."
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

    return unless my_item?(params[:dlg_evt_edit_comp][:id])# check permission

    @projectcomp = DatProjectcomp.find(:first,
                          :conditions => [" dat_projectcomps.id = ? ", params[:dlg_evt_edit_comp][:id]],
                          :include =>[{:dat_event=>[:dat_eventusers]}] )
    @projectcomp.update_user_id = session_user_id
    @projectcomp.last_operation_kbn = 3
    @event = @projectcomp.dat_event
    @event.update_user_id = session_user_id
    @event.last_operation_kbn = 3


    @event.dat_eventusers.clear  
    if ! params[:dlg_evt_edit_eventusers].nil?
      for puser in params[:dlg_evt_edit_eventusers][:projectuser_id]
        eventuser = @event.dat_eventusers.build(:projectuser_id=>puser)
        eventuser.create_user_id = session_user_id
      end
    end

    if ! @projectcomp.update_attributes(params[:dlg_evt_edit_comp])
      message = "Error in updating project component."
      render :text => result_for_json(false, message, {})
      return
    end

    if ! @event.update_attributes(params[:dlg_evt_edit_event])
      message = "Error in updating Event."
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
      message = "Error in deleting Event."
      render :text => result_for_json(false, message, {})
      return
    end

    respond_to do |f|
      f.html { redirect_to :action => index }
      f.json { render :text => result_for_json(true, '', {})}
    end
  end

end
