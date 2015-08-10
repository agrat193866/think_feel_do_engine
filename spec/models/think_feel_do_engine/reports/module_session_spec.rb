require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe ModuleSession do
      fixtures :all

      let(:data) { ModuleSession.all }

      describe ".all" do
        def render!(emitted_at:, url:)
          EventCapture::Event.create!(
            emitted_at: emitted_at,
            recorded_at: emitted_at,
            payload: { currentUrl: url, headers: %w( a b c ) },
            kind: "render",
            participant_id: participants(:participant1).id
          )
        end

        context "when no modules were viewed" do
          it "returns an empty array" do
            EventCapture::Event.destroy_all

            expect(data).to be_empty
          end
        end

        it "excludes non-didactic modules" do
          Task.destroy_all

          expect(data.count).to eq 0
        end

        context "when modules were viewed" do
          it "returns accurate summaries" do
            first_render_event = event_capture_events(:event_capture_events_014)
            last_render_event = event_capture_events(:event_capture_events_031)
            expect(data).to include(
              participant_id: "TFD-1111",
              module_id: bit_core_content_modules(:think_identifying).id,
              page_headers: ["THINK", "#1 Identifying", "You are what you " \
                             "think...Your thoughts shape and guideThoughts " \
                             "are the exact sentences that go through your " \
                             "head."],
              module_selected_at: first_render_event.emitted_at.iso8601,
              last_page_opened_at: last_render_event.emitted_at.iso8601,
              did_complete: true
            )
          end
        end

        context "when the same module is viewed in one session" do
          it "returns accurate summaries" do
            EventCapture::Event.destroy_all
            now = Time.current
            module1_id = bit_core_content_modules(:do_awareness).id
            module2_id = bit_core_content_modules(:do_planning).id
            render!(emitted_at: now - 10.minutes,
                    url: "/navigator/modules/#{ module1_id }")
            render!(emitted_at: now - 9.minutes,
                    url: "/navigator/modules/#{ module1_id }")
            render!(emitted_at: now - 8.minutes,
                    url: "/navigator/modules/#{ module2_id }")

            expect(data.count).to eq 2
            expect(data).to include(
              participant_id: "TFD-1111",
              module_id: module1_id,
              page_headers: ["a", "b", "c"],
              module_selected_at: (now - 10.minutes).utc.iso8601,
              last_page_opened_at: (now - 9.minutes).utc.iso8601,
              did_complete: false
            )
          end
        end

        context "when there was a gap in page views" do
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
              last_page_opened_at: (now - 8.minutes).utc.iso8601,
              did_complete: false
            )
          end
        end
      end
    end
  end
end
