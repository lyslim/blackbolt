class DashboardsController < ApplicationController

  # index
  # map.root
  def show
    if user_signed_in?
      redirect_to projects_path
    else 
      redirect_to new_user_session_path
    end   
  end
end
