module ThinkFeelDoEngine
  module Users
    # Customize User password actions.
    class PasswordsController < Devise::PasswordsController
      protected

      def after_resetting_password_path_for(_resource)
        if defined?(think_feel_do_dashboard)
          think_feel_do_dashboard.root_path
        else
          privacy_policy_path
        end
      end
    end
  end
end
