class DashboardsController < ApplicationController

  # index
  # map.root
  def show
    if user_signed_in?
      redirect_to projects_path
    end
  end
end
