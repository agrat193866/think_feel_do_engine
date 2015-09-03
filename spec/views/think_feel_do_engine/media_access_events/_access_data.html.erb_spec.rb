require "rails_helper"

module ThinkFeelDoEngine
  RSpec.describe "think_feel_do_engine/media_access_events/_access_data.html.erb",
                 type: :view do
    let(:partial) { "think_feel_do_engine/media_access_events/access_data" }
    let(:presenter) do
      instance_double(
        MediaAccessEventPresenter,
        sortable: "sort_me",
        title: "foo",
        available_on: "future",
        formatted_start_time: "start me",
        formatted_end_time: "end me",
        completed: true,
        duration_of_session: "long time")
    end

    def render_partial
      render partial: partial
    end

    before do
      allow(view).to receive(:event)
      allow(view)
        .to receive(:present) { |&block| block.call(presenter) }

      expect(view)
        .to receive(:distance_of_time_in_words)
        .with("long time")

      render_partial
    end

    describe "event is completed" do
      it "renders sortable data" do
        expect(rendered).to have_text "sort_me"
      end

      it "displays slide title" do
        expect(rendered).to have_text "foo"
      end

      it "displays when available" do
        expect(rendered).to have_text "future"
      end

      it "displays when the participant started the event" do
        expect(rendered).to have_text "start me"
      end

      it "displays when the participant ended the event" do
        expect(rendered).to have_text "end me"
      end

      it "does not display incomplete messages" do
        expect(rendered).to_not have_text "Not Completed"
      end
    end

    describe "event is not completed" do
      before do
        allow(presenter).to receive(:completed) { false }
      end

      it "displays incomplete messages" do
        render_partial

        expect(rendered).to have_text "Not Completed"
      end
    end
  end
end
