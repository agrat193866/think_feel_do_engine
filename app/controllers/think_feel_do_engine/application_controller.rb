require "cancan"

module ThinkFeelDoEngine
  # Site-wide controller superclass.
  class ApplicationController < ActionController::Base
    include ThinkFeelDoEngine::Concerns::BrowserDetective

    protect_from_forgery with: :exception

    before_action :detect_browser

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
  end
end
