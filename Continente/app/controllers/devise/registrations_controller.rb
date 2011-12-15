class Devise::RegistrationsController < ApplicationController
  before_filter :authenticate_user!
  include Devise::Controllers::InternalHelpers
  
  def new
    return if auth("website_administrator")
    resource = build_resource({})
    respond_with_navigational(resource){ render_with_scope :new }
  end
  
  def create
    auth("website_administrator")
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        redirect_to root_path
      else
        set_flash_message :notice, :inactive_signed_up, :reason => inactive_reason(resource) if is_navigational_format?
        expire_session_data_after_sign_in!
        redirect_to root_path
      end
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource) { render_with_scope :new }
    end
  end
  
#  def update
#    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

#    if resource.update_with_password(params[resource_name])
#      if is_navigational_format?
#        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
#          flash_key = :update_needs_confirmation
#        end
#        set_flash_message :notice, flash_key || :updated
#      end
#      sign_in resource_name, resource, :bypass => true
#      respond_with resource, :location => after_update_path_for(resource)
#    else
#      clean_up_passwords(resource)
#      respond_with_navigational(resource){ render_with_scope :edit }
#    end
#  end
  
  private
  
  def authenticate_scope!
      send(:"authenticate_#{resource_name}!", :force => true)
      self.resource = send(:"current_#{resource_name}")
    end

end
