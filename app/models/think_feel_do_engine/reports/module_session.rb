require "csv"

module ThinkFeelDoEngine
  module Reports
    # Scenario: A Participant starts using a Tool Module.
    class ModuleSession
      include ToolModule

      def self.all
        interactions = all_module_interactions

        # condense adjacent interactions
        filtered_interactions = []
        interactions.each_with_index do |interaction, i|
          previous_interaction = interactions[i - 1] || {}
          next if previous_interaction[:participant_id] ==
                  interaction[:participant_id] &&
                  previous_interaction[:module_id] == interaction[:module_id]

          filtered_interaction = interaction.clone

          (i + 1..interactions.length - 1).each do |j|
            next_interaction = interactions[j]
            next unless next_interaction[:participant_id] ==
                        interaction[:participant_id] &&
                        next_interaction[:module_id] ==
                        interaction[:module_id]

            filtered_interaction[:last_page_opened_at] =
              next_interaction[:last_page_opened_at]
          end

          filtered_interactions << filtered_interaction
        end

        filtered_interactions
      end

      def self.to_csv
        CSV.generate do |csv|
          columns = %w( participant_id module_id page_headers
                        module_selected_at last_page_number_opened
                        last_page_opened_at )
          csv << columns
          Reports::ModuleSession.all.each do |s|
            csv << columns.map { |c| s[c.to_sym] }
          end
        end
      end

      def self.all_module_interactions
        modules = module_entries_map

        Participant.select(:id, :study_id).map do |participant|
          events = EventCapture::Event
                   .where(participant_id: participant.id, kind: "click")
                   .select(:participant_id, :emitted_at, :payload, :kind)
                   .to_a
                   .sort { |a, b| a.emitted_at <=> b.emitted_at }
          module_select_events = events.select do |e|
                                          modules.keys.include?(
                                            e.current_url.gsub(URL_ROOT_RE, "")
                                          )
                                        end

          module_select_events.map do |e|
            module_id = modules[e.current_url.gsub(URL_ROOT_RE, "")]
            last_page_opened = last_page_opened(events, e, module_id)

            {
              participant_id: participant.study_id,
              module_id: module_id,
              page_headers: e.headers,
              module_selected_at: e.emitted_at.iso8601,
              last_page_number_opened: last_page_opened[:number],
              last_page_opened_at: last_page_opened[:opened_at].iso8601
            }
          end
        end.flatten
      end

      # last event (click) with matching module id
      def self.last_page_opened(events, first_session_event, module_id)
        module_events =
          events
          .drop_while { |e| e.id != first_session_event.id }
          .take_while { |e| e.current_url.include?(module_id.to_s) }
        last_event = (module_events.last || first_session_event)
        number = 1
        unless last_event.current_url.match(/providers\/\d+\/\d+$/).nil?
          number = last_event.current_url[/\d+$/]
        end

        {
          number: number,
          opened_at: last_event.emitted_at
        }
      end
    end
  end
end
