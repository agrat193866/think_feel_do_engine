module ThinkFeelDoEngine
  module Users
    # Extends the Devise controller to notify users
    # if they don't have a role
    class SessionsController < Devise::SessionsController
      layout "application"

      skip_authorization_check

      # Ignoring cops due to external code use.
      # rubocop:disable Metrics/LineLength
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def create
        user = User.find_by_email params[:user][:email]
        if user && !user.admin? && user.user_roles.count == 0
          msg = "We're sorry, but you need to have a role to continue.\
                Contact your administrator."
          redirect_to new_user_session_path, alert: msg
        else
          # super...http://bit.ly/1uXh4rb
          self.resource = warden.authenticate!(auth_options)
          set_flash_message(:notice, :signed_in) if is_flashing_format?
          sign_in(resource_name, resource)
          yield resource if block_given?
          respond_with resource,
                       location:
                         (defined?(think_feel_do_dashboard) ? think_feel_do_dashboard.root_path : privacy_policy_path)
        end
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
