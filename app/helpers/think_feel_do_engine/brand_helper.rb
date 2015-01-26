module ThinkFeelDoEngine
  # Used for navigation link generation when the user is not authorized.
  module BrandHelper

    # Uses the authorization state and contextual path to determine
    # the page branding link url.
    def brand_location
      if authorized_user_with_dashboard? ||
         no_authorization_and_user_password_update_page?
        think_feel_do_dashboard.root_path
      elsif no_authorization_and_sign_in_page?
        "#"
      else
        main_app.root_url
      end
    end

    private

    def authorized_user_with_dashboard?
      defined?(think_feel_do_dashboard) && current_user
    end

    def no_authorization_and_sign_in_page?
      !current_user &&
        !current_participant &&
          (current_page?(Engine.routes.url_helpers.new_user_session_path) ||
            current_page?(Engine.routes.url_helpers.new_participant_session_path))
    end

    def no_authorization_and_user_password_update_page?
      !current_user &&
        !current_participant &&
          current_page?(Engine.routes.url_helpers.new_user_password_path)
    end
  end
end