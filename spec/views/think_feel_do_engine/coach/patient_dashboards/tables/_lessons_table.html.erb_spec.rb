require "rails_helper"

RSpec.describe "think_feel_do_engine/coach/patient_dashboards" \
               "tables/_lessons_table.html.erb_spec.rb",
               type: :view do
  context "Events exist" do
    let(:lesson_title) { "LEARN - BiG LeSsOn!" }
    let(:lesson) { double("lesson", title: lesson_title) }
    let(:header) { "Meet Joe" }
    let(:events) do
      [
        {
          page_headers: ["", "", header],
          lesson_selected_at: "2015-01-21T16:21",
          last_page_number_opened: 1,
          last_page_opened_at: "2015-02-22T15:43"
        }
      ]
    end

    before :each do
      allow(ContentModules::LessonModule).to receive(:find).and_return(lesson)
      assign(:lesson_events, events)
      render partial: "think_feel_do_engine/coach/" \
                      "patient_dashboards/tables/lessons_table"
    end

    it "displays lesson table headings" do
      expect(rendered).to have_text "Lesson Title"
      expect(rendered).to have_text "Lesson Page"
      expect(rendered).to have_text "Lesson Selected At"
      expect(rendered).to have_text "Last Page Number Opened"
      expect(rendered).to have_text "Last Page Opened At"
    end

    it "displays related lesson event click data attributes" do
      expect(rendered).to have_text lesson_title
      expect(rendered).to have_text header
      expect(rendered).to have_text "Jan 21 2015 16:21"
      expect(rendered).to have_text "Feb 22 2015 15:43"
    end
  end

  context "An event's page header is nil" do
    let(:lesson) { double("lesson", title: "Think, Feel, Do Your Way Out of Depression") }

    before :each do
      allow(ContentModules::LessonModule).to receive(:find).and_return(lesson)
      assign(:lesson_events, [
        {
          page_headers: nil,
          lesson_selected_at: "2015-01-21T16:21",
          last_page_number_opened: 1,
          last_page_opened_at: "2015-02-22T15:43"
        }
      ])
      render partial: "think_feel_do_engine/coach/" \
                      "patient_dashboards/tables/lessons_table"
    end

    it "will render the table" do
      expect(rendered).to have_text "Think, Feel, Do Your Way Out of Depression"
    end
  end
end
