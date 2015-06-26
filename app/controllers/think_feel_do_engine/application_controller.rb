require "cancan"

module ThinkFeelDoEngine
  # Site-wide controller superclass.
  class ApplicationController < ActionController::Base
    include ThinkFeelDoEngine::Concerns::BrowserDetective

    INACTIVE_MESSAGE = "We're sorry, but you can't sign in yet "\
              "because you are not assigned to an active group."

    protect_from_forgery with: :exception

    before_action :detect_browser, :verify_active_membership

    layout "application"

    def after_sign_in_path_for(resource)
      if resource.class == User
        if defined?(think_feel_do_dashboard)
          think_feel_do_dashboard.root_path
        else
          privacy_policy_path
        end

      else
        super resource
      end
    end

    def after_sign_out_path_for(resource)
      session[:previous_url] || (
        resource == :participant ? main_app.root_path : new_user_session_path
      )
    end

    def access_denied_resource_path
      if defined?(think_feel_do_dashboard)
        think_feel_do_dashboard.root_path
      else
        privacy_policy_path
      end
    end

    rescue_from CanCan::AccessDenied do |exception|
      if current_user.coach?
        redirect_to access_denied_resource_path, alert: exception.message
      else
        redirect_to main_app.root_path, alert: exception.message
      end
    end

    private

    def phq_features?
      if Rails.application.config.respond_to?(:include_phq_features)
        Rails.application.config.include_phq_features
      end
    end
    helper_method :phq_features?

    def social_features?
      if Rails.application.config.respond_to?(:include_social_features)
        Rails.application.config.include_social_features
      end
    end
    helper_method :social_features?

    def verify_active_membership
      if current_participant && !current_participant.active_membership
        scope = Devise::Mapping.find_scope!(current_participant)
        Devise.sign_out_all_scopes ? sign_out : sign_out(scope)
        redirect_to new_participant_session_path, alert: INACTIVE_MESSAGE
      end
    end
  end
end
