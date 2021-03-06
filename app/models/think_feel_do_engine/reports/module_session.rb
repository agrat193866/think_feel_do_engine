module ThinkFeelDoEngine
  module Reports
    # Scenario: A Participant starts using a Tool Module.
    class ModuleSession
      include ToolModule

      THRESHOLD = 5.minutes

      def self.columns
        %w( participant_id module_id page_headers module_selected_at
            last_page_opened_at did_complete )
      end

      def self.all
        all_module_interactions
          .group_by { |i| i[:participant_id] }
          .map do |_participant_id, interactions|
          # condense adjacent interactions
          filtered_interactions = [nice_times(interactions.first.clone)].compact
          interactions.each_with_index do |interaction, i|
            previous_interaction = interactions[i - 1] || {}
            next if previous_interaction[:module_id] == interaction[:module_id]

            filtered_interaction = interaction.clone

            (i + 1..interactions.length - 1).each do |j|
              next_interaction = interactions[j]
              break if next_interaction[:module_id] != interaction[:module_id]

              next unless next_interaction[:last_page_opened_at] -
                          filtered_interaction[:last_page_opened_at] < THRESHOLD

              filtered_interaction[:last_page_opened_at] =
                next_interaction[:last_page_opened_at]
            end

            filtered_interactions << nice_times(filtered_interaction)
          end

          filtered_interactions.uniq
        end.flatten
      end

      # Returns all events that represent a viewing (render) of a Content
      # Module.
      def self.all_module_interactions
        modules = modules_map.keys.each_with_object({}) do |key, h|
          if Task.exists?(bit_core_content_module_id: modules_map[key].id,
                          has_didactic_content: true)
            h[key] = modules_map[key]
          end
        end

        Participant.select(:id, :study_id).map do |participant|
          events = time_sorted_render_events_for(participant)

          events.map do |e|
            content_module = modules[e.current_url.gsub(URL_ROOT_RE, "")]

            next unless content_module

            last_page_opened = last_page_opened(events, e, content_module.id)

            {
              participant_id: participant.study_id,
              module_id: content_module.id,
              page_headers: e.headers,
              module_selected_at: e.emitted_at,
              last_page_opened_at: last_page_opened[:opened_at],
              did_complete: last_page_opened[:is_last_module_page]
            }
          end.compact
        end.flatten
      end

      def self.time_sorted_render_events_for(participant)
        EventCapture::Event
          .where(participant_id: participant.id, kind: "render")
          .select(:id, :participant_id, :emitted_at, :payload, :kind)
          .to_a.sort { |a, b| a.emitted_at <=> b.emitted_at }
      end

      # last event (click) with matching module id
      def self.last_page_opened(events, first_session_event, module_id)
        latest_event_time = first_session_event.emitted_at
        module_events =
          events
          .drop_while { |e| e.id != first_session_event.id }
          .take_while do |e|
            e.emitted_at - latest_event_time < THRESHOLD &&
            e.current_url.match(/modules\/#{ module_id }(\/.*)?$/) &&
            (latest_event_time = e.emitted_at)
          end
        last_event = (module_events.last || first_session_event)

        {
          opened_at: last_event.emitted_at,
          is_last_module_page: is_last_module_page(last_event.current_url,
                                                   module_id)
        }
      end

      def self.nice_times(interaction)
        interaction[:module_selected_at] =
          interaction[:module_selected_at].iso8601
        interaction[:last_page_opened_at] =
          interaction[:last_page_opened_at].iso8601

        interaction
      end

      def self.is_last_module_page(url, module_id)
        # last provider within module
        last_provider = BitCore::ContentModule.find(module_id)
                        .content_providers
                        .order(:position)
                        .last

        if last_provider.nil?
          false
        else
          provider_re = "modules\/#{ module_id }\/" \
                        "providers\/#{ last_provider.id }(\/.*)?$"

          !url.match(/#{ provider_re }/).nil?
        end
      end
    end
  end
end
