module ThinkFeelDoEngine
  # Provides the static privacy policy page.
  class PrivacyPoliciesController < ApplicationController
    layout "application"

    skip_authorization_check

    def show
    end
  end
end
