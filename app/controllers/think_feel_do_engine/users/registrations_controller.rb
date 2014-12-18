class RegistrationsController < Devise::RegistrationsController

  protected

  def after_update_path_for(resource)
    (defined?(think_feel_do_dashboard) ? think_feel_do_dashboard.root_path : "#")
  end
end