class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end

  private
  def after_sign_out_path_for(resource_or_scope)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    send(:"new_#{scope}_session_path")
  end
end
