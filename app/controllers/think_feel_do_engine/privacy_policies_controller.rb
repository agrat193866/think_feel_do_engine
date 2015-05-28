module ThinkFeelDoEngine
  # Provides the static privacy policy page.
  class PrivacyPoliciesController < ApplicationController
    layout :determine_layout

    skip_authorization_check

    def show
    end

    def determine_layout
      current_participant ? "tool" : "application"
    end
  end
end
