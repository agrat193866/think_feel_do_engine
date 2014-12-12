class RegistrationsController < Devise::RegistrationsController

  protected

  def after_update_path_for(resource)
    arms_path
  end
end