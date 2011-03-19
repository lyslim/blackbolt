class DatEvent < ActiveRecord::Base

  # (1:1)
  belongs_to :dat_projectcomp, :foreign_key => "project_tree_id"
  # (1:n)
  has_many :dat_eventusers, :foreign_key => "event_id", :dependent=>:destroy

  def copyFromTemplate(template)
    self.attributes.each_pair do | key, value |
      case key.to_s
      when "create_user_id"
      when "created_on"
      when "update_user_id"
      when "updated_on"
      else
        if ! template[key.to_s].nil?
          self[key.to_s] = template[key.to_s]
        end
      end
    end
  end

end
