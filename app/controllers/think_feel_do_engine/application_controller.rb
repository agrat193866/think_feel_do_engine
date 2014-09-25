require "cancan"

module ThinkFeelDoEngine
  # Site-wide controller superclass.
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    def after_sign_in_path_for(resource)
      if resource.class == User
        manage_groups_path
      else
        ParticipantAuthenticationPolicy.new(self, resource).post_sign_in_path
      end
    end

    def after_sign_out_path_for(resource)
      session[:previous_url] || (
        resource == :participant ? main_app.root_path : new_user_session_path
      )
    end

    rescue_from CanCan::AccessDenied do |exception|
      if current_user.coach?
        redirect_to "/coach/messages", alert: exception.message
      else
        redirect_to main_app.root_path, alert: exception.message
      end
    end
  end
end
