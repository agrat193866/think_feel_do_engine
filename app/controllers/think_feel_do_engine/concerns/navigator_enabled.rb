require "bit_player"

module ThinkFeelDoEngine
  module Concerns
    # Provides helpers for managing the Navigator.
    module NavigatorEnabled
      extend ActiveSupport::Concern

      private

      def instantiate_navigator
        @navigator ||= BitPlayer::Navigator.new(current_participant)
      end
    end
  end
end
