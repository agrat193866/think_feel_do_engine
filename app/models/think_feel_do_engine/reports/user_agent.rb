require "user_agent_parser"

module ThinkFeelDoEngine
  module Reports
    # Scenario: a Participant accesses the site with a unique user agent.
    class UserAgent
      def self.columns
        %w( participant_id user_agent_family user_agent_version user_agent_os )
      end

      def self.all
        Participant.select(:id, :study_id).map do |participant|
          user_agents = EventCapture::Event
                        .where(participant_id: participant.id)
                        .map { |event| event.payload[:ua] }
                        .uniq

          user_agents.map do |agent|
            ua = UserAgentParser.parse(agent)
            next if ua.family == "Other" && ua.version.to_s == ""

            {
              participant_id: participant.study_id,
              user_agent_family: ua.family,
              user_agent_version: ua.version.to_s,
              user_agent_os: ua.os.to_s
            }
          end
        end.flatten.compact
      end
    end
  end
end
