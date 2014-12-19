class RegistrationsController < Devise::RegistrationsController
  skip_authorization_check

  protected

  def after_update_path_for(resource)
    (defined?(think_feel_do_dashboard) ? think_feel_do_dashboard.root_path : privacy_policy_path)
  end
end