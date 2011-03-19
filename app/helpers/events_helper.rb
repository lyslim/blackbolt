module EventsHelper

  def select_for_eventusers(variable, attribute, options, html_options)
    insobj = instance_variable_get("@#{variable}")
    if insobj == nil
      select( variable, attribute, {}, options, html_options)
    end

  end

  def list_for_eventusers(event_id)
    choises = Array.new
    if event_id.nil?
      choises = choises
    else
      users = DatEventuser.find(:all,
                                  :conditions=>["event_id = ?", event_id],
                                  :include=>[{:dat_projectuser=>:mst_user}])
      choises = users.map{
                            |u| [(u.dat_projectuser.mst_user.nil? ? u.dat_projectuser.email : u.dat_projectuser.mst_user.user_name), u.projectuser_id]
                          }
    end

    return choises
  end

  def object_for_eventusers(event_id)
    objects = Array.new
    if event_id.nil?
      objects = objects
    else

      users = DatEventuser.find(:all,
                                  :conditions=>["event_id = ?", event_id],
                                  :include=>[{:dat_projectuser=>:mst_user}])
      objects = users.map{
                            |u| {:user_name=>(u.dat_projectuser.mst_user.nil? ? u.dat_projectuser.email : u.dat_projectuser.mst_user.user_name), :projectuser_id=>u.projectuser_id}
                          }
    end

    return objects
  end

  def time_text_field(variable, attribute, options)
    year = Time.now.year.to_s 
    month = Time.now.month.to_s 
    day = Time.now.day.to_s 
    hour = ""
    minute = ""
    if (obj = instance_variable_get("@#{variable}"))
      if ! obj[attribute].nil?
        value = obj[attribute]
        year = value.year.to_s
        month = value.month.to_s
        day = value.day.to_s
        hour = value.hour.to_s
        minute = value.min.to_s
      end
    end

    return "<input type='hidden' id='#{variable}_#{attribute}_1i' name='#{variable}[#{attribute}(1i)]' value='#{year}'>" +
    "<input type='hidden' id='#{variable}_#{attribute}_2i' name='#{variable}[#{attribute}(2i)]' value='#{month}'>" +
    "<input type='hidden' id='#{variable}_#{attribute}_3i' name='#{variable}[#{attribute}(3i)]' value='#{day}'>" +
    "<input type='text' id='#{variable}_#{attribute}_4i' name='#{variable}[#{attribute}(4i)]' value='#{hour}' style='width:30px;ime-mode:disabled;text-align:right;' maxlength='2'> ： " +
    "<input type='text' id='#{variable}_#{attribute}_5i' name='#{variable}[#{attribute}(5i)]' value='#{minute}' style='width:30px;ime-mode:disabled;text-align:right;' maxlength='2'>"
  end
end
