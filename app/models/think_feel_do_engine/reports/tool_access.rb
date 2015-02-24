require "csv"

module ThinkFeelDoEngine
  module Reports
    # Scenario: a Participant accesses a Tool Module.
    class ToolAccess
      def self.all
        Participant.select(:id, :study_id).map do |participant|
          tool_access_events(participant).map do |tool_access|
            {
              participant_id: participant.study_id,
              module_title: tool_access[:title],
              came_from: tool_access[:source],
              occurred_at: tool_access[:time]
            }
          end
        end.flatten
      end

      def self.to_csv
        CSV.generate do |csv|
          columns = %w( participant_id module_title came_from occurred_at )
          csv << columns
          Reports::ToolAccess.all.each do |s|
            csv << columns.map { |c| s[c.to_sym] }
          end
        end
      end

      def self.tool_access_events(participant)
        sources = {
          "list-group left" => "Tool home",
          "list-group right" => "Tool home",
          "<li>" => "Nav menu",
          '<li class="list-group-item' => "To do list"
        }
        module_titles = BitCore::ContentModule.all.map(&:title)

        EventCapture::Event
          .where(kind: "click", participant_id: participant.id).map do |e|
            title = module_titles.find do |t|
              e.payload["buttonHtml"].include?(t)
            end
            source = sources.keys.find do |s|
              e.payload["parentHtml"].try(:include?, s)
            end

            next unless title && source

            {
              title: title,
              source: sources[source],
              time: e.emitted_at
            }
          end.compact
      end
    end
  end
end
