class User < ActiveRecord::Base
  ROLES = %w[website_administrator ims_servicedesk ims_infrastructureresponsible ims_suppliersmanager ims_technicalstaff ims_boardofdirectors]
  ROLES_TITLES = {"website_administrator" => "Website Administrator", "ims_servicedesk" => "Service Desk", "ims_infrastructureresponsible" => "Infrastructure Responsible", "ims_suppliersmanager" => "Suppliers Manager", "ims_technicalstaff" => "Technical Staff", "ims_boardofdirectors" => "Board of Directors"}
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :roles
  
  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end
end
