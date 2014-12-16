# Customize User registrations.
class RegistrationsController < Devise::RegistrationsController
  protected

  def after_update_path_for(_resource)
    "/arms"
  end
end
