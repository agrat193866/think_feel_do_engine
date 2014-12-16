module ThinkFeelDoEngine
  module Users
    # Customize User password actions.
    class PasswordsController < Devise::PasswordsController
      protected

      def after_resetting_password_path_for(_resource)
        "/arms"
      end
    end
  end
end
