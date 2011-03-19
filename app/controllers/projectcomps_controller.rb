class ProjectcompsController < ApplicationController

  ###########################################################
  # Method: Update the line item
  # Abstract: The line number of the item to update
  ###########################################################
  def item_order_update

    id = params[:id]
    offset = params[:offset]

    return unless my_item?(params[:id])# check permission

    # retrieve target
    target = DatProjectcomp.find(id)

    # replace
    if offset.to_i > 0
      replacement = DatProjectcomp.find(:first,
                                        :conditions=>[" project_id=? AND line_no > ?", target.project_id, target.line_no],
                                        :order=>"line_no asc"
                                        )
    else
      replacement = DatProjectcomp.find(:first,
                                        :conditions=>[" project_id=? AND line_no < ?", target.project_id, target.line_no],
                                        :order=>"line_no desc"
                                        )
    end

    # if the target is replaced, replace the line number
    if ! replacement.nil?
      target_line_no = replacement.line_no
      replacement.line_no = target.line_no
      target.line_no = target_line_no
      
      target.save
      replacement.save
    end

    respond_to do |f|
      f.json { render :text => result_for_json(true, '', {}) }
    end
  end
end
