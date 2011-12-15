class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new
    if user.ims_servicedesk?
      can :ims_servicedesk, :all
    if user.ims_infrastructureresponsible?
      can :ims_infrastructureresponsible, :all
    if user.ims_suppliersmanager?
      can :ims_suppliersmanager, :all
    if user.ims_technicalstaff?
      can :ims_technicalstaff, :all
    if user.ims_boardofdirectors?
      can :ims_boardofdirectors, :all
    end
  end
end
