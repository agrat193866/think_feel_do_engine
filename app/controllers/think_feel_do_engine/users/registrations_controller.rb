# Overridden methods for the registrations controller of Devise
class RegistrationsController < Devise::RegistrationsController
  skip_authorization_check

  protected

  # rubocop:disable Lint/UnusedMethodArgument
  def after_update_path_for(resource)
    if defined?(think_feel_do_dashboard)
      think_feel_do_dashboard.root_path
    else
      privacy_policy_path
    end
  end
  # rubocop:enable Lint/UnusedMethodArgument
end