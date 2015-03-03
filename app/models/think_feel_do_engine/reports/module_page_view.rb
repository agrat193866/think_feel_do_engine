module ThinkFeelDoEngine
  module Reports
    # Scenario: A Participant starts using a Module page.
    class ModulePageView
      include ToolModule

      def self.columns
        %w( participant_id tool_id module_id page_headers page_selected_at
            page_exited_at )
      end

      def self.all
        modules = modules_map

        Participant.select(:id, :study_id).map do |participant|
          # find all module rendering events
          slide_render_events = EventCapture::Event
                                .where(participant_id: participant.id,
                                       kind: %w( render ))
                                .select(:participant_id, :emitted_at, :payload)
                                .to_a.map do |e|
                                  key = modules.keys.find do |l|
                                    !e.current_url.match(/#{ l }(\/.*)?$/).nil?
                                  end

                                  key ? [modules[key], e] : nil
                                end.compact

          slide_render_events.map do |module_event|
            e = module_event[1]
            mod = module_event[0]

            {
              participant_id: participant.study_id,
              tool_id: mod.bit_core_tool_id,
              module_id: mod.id,
              page_headers: e.headers,
              page_selected_at: e.emitted_at.iso8601,
              page_exited_at: page_exit_event_at(e).try(:iso8601)
            }
          end
        end.flatten
      end

      def self.to_csv
        Reporter.new(self).to_csv
      end

      def self.page_exit_event_at(page_render_event)
        EventCapture::Event
          .order(:emitted_at)
          .where("emitted_at > ? AND payload NOT LIKE ?",
                 page_render_event.emitted_at,
                 "%currentUrl: #{ page_render_event.current_url }\n%")
          .select(:emitted_at).limit(1).first.try(:emitted_at)
      end
    end
  end
end
