require "active_record/fixtures"

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      # PostgreSQL only disables referential integrity when connection
      # user is root and that is not the case.
      def disable_referential_integrity
        yield
      end
    end
  end
end

namespace :seed do
  desc "seed the database with fixtures from spec/fixtures"
  task with_think_feel_do_engine_fixtures: :environment do
    path = File.join(File.dirname(__FILE__), "..", "..", "spec", "fixtures")
    ActiveRecord::FixtureSet.create_fixtures path, [
      :arms, :participants, :"bit_core/slideshows", :"bit_core/slides",
      :"bit_core/tools", :"bit_core/content_modules",
      :"bit_core/content_providers", :content_provider_policies, :users, :user_roles, :activity_types,
      :activities, :coach_assignments, :groups, :memberships, :messages,
      :delivered_messages, :thought_patterns, :thoughts,
      :tasks, :task_status, :moods, :phq_assessments, :emotions,
      :emotional_ratings, :media_access_events, :awake_periods, :slideshow_anchors
    ]
  end
end
