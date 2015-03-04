require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe ModuleSession do
      fixtures :all

      def data
        @data ||= ModuleSession.all
      end

      describe ".all" do
        context "when no modules were viewed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(data).to be_empty
          end
        end

        context "when modules were viewed" do
          it "returns accurate summaries" do
            first_render_event = event_capture_events(:event_capture_events_014)
            last_render_event = event_capture_events(:event_capture_events_031)
            expect(data.count).to eq 7
            expect(data).to include(
              participant_id: "TFD-1111",
              module_id: bit_core_content_modules(:think_identifying).id,
              page_headers: ["THINK", "#1 Identifying", "You are what you " \
                             "think...Your thoughts shape and guideThoughts " \
                             "are the exact sentences that go through your " \
                             "head."],
              module_selected_at: first_render_event.emitted_at.iso8601,
              last_page_opened_at: last_render_event.emitted_at.iso8601
            )
          end
        end

        context "when there was a gap in page views" do
          def render!(emitted_at:, url:)
            EventCapture::Event.create!(
              emitted_at: emitted_at,
              recorded_at: emitted_at,
              payload: { currentUrl: url, headers: %w( a b c ) },
              kind: "render",
              participant_id: participants(:participant1).id
            )
          end

          it "returns accurate summaries" do
            EventCapture::Event.destroy_all
            now = Time.current
            module_id = bit_core_content_modules(:do_awareness).id
            render!(emitted_at: now - 10.minutes,
                    url: "/navigator/modules/#{ module_id }")
            render!(emitted_at: now - 9.minutes,
                    url: "/navigator/modules/#{ module_id }/providers/123/1")
            render!(emitted_at: now - 8.minutes,
                    url: "/navigator/modules/#{ module_id }/providers/123/2")
            render!(emitted_at: now - 1.minute,
                    url: "/navigator/modules/#{ module_id }/providers/123/3")

            expect(data.count).to eq 1
            expect(data).to include(
              participant_id: "TFD-1111",
              module_id: module_id,
              page_headers: ["a", "b", "c"],
              module_selected_at: (now - 10.minutes).utc.iso8601,
              last_page_opened_at: (now - 8.minutes).utc.iso8601
            )
          end
        end
      end
    end
  end
end
