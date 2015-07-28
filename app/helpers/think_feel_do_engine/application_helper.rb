module ThinkFeelDoEngine
  # Ensure font awesome icon helpers are available.
  module ApplicationHelper
    include FontAwesome::Rails::IconHelper

    def host_email_link
      host_url = Rails.application.config.action_mailer
                 .default_url_options[:host]
      host_url if host_url
    end

    def phq_features?
      if Rails.application.config.respond_to?(:include_phq_features)
        Rails.application.config.include_phq_features
      end
    end

    def social_features?
      if Rails.application.config.respond_to?(:include_social_features)
        Rails.application.config.include_social_features
      end
    end
  end
end
