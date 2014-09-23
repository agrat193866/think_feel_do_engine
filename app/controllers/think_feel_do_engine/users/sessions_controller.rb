module ThinkFeelDoEngine
  module Users
    # Extends the Devise controller to notify users
    # if they don't have a role
    class SessionsController < Devise::SessionsController
      def create
        user = User.find_by_email params[:user][:email]
        if user && !user.admin? && user.user_roles.count == 0
          msg = "We're sorry, but you need to have a role to continue.\
                Contact your administrator."
          redirect_to new_user_session_path, alert: msg
        else
          super
        end
      end
    end
  end
end
