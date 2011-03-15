class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :http_authenticatable, :token_authenticatable, :lockable, :timeoutable and :activatable
  devise :registerable, :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable, :confirmable
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :sap_name, :email, :password, :password_confirmation
  
  # projects
  has_many :dat_projectusers, :foreign_key => 'user_id', :dependent => :destroy
  has_many :dat_projects, :class_name => 'DatProject', :through => :dat_projectusers


  def my_active_projects()
    opt = {
      :conditions => ["valid_flg = ? AND dat_projectusers.active_flg = ?", 1, 1],
      :include    => [:dat_projectusers]
    }
    dat_projects.find(:all, opt)
  end
end
