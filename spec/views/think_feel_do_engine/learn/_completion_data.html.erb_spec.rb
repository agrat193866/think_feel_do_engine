require "rails_helper"

module ThinkFeelDoEngine
  RSpec.describe "think_feel_do_engine/learn/_completion_data.html.erb",
                 type: :view do
    let(:partial) { "think_feel_do_engine/learn/completion_data" }
    let(:current) { DateTime.current }
    let(:two_seconds_later) { current + 2.seconds }
    let(:presenter) do
      instance_double(
        LessonEvent::CompletionDataPresenter,
        selected_at: current,
        last_page_opened_at: two_seconds_later,
        pretty_title: "foo",
        last_page_number_opened: "bar",
        page_headers: "Camus")
    end

    describe "A learning event exists" do
      before do
        allow(view).to receive(:lesson_event)
        allow(view)
          .to receive(:present) { |&block| block.call(presenter) }

        render partial: partial
      end

      it "displays when the participant started the lesson as an integer for sorting" do
        expect(rendered).to have_text current.to_i
      end

      it "displays when the last page was opened as an integer for sorting" do
        expect(rendered).to have_text two_seconds_later.to_i
      end

      it "displays when the participant started the lesson" do
        expect(rendered).to have_text current.to_s(:with_seconds)
      end

      it "displays when the last page was opened" do
        expect(rendered).to have_text two_seconds_later.to_s(:with_seconds)
      end

      it "displays the page headers" do
        expect(rendered).to have_text "Camus"
      end

      it "displays the title of the slide" do
        expect(rendered).to have_text "foo"
      end

      it "displays the number of the last page" do
        expect(rendered).to have_text "bar"
      end

      it "displays the duration of how long the slideshow was viewed" do
        expect(rendered).to have_text "less than 5 seconds"
      end
    end
  end
end
