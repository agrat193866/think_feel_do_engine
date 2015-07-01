require "rails_helper"

RSpec.describe "think_feel_do_engine/coach/patient_dashboards/" \
               "_phq_summary", type: :view do
  fixtures :all

  let(:phq_assessments) do
    double(
      "phq_stepping_assessment",
      date: Date.new(2015, 6, 15),
      missing_answers_count: 1,
      missing_but_copied: "",
      missing_with_no_fallback: "",
      score: 1,
      week_of_assessment: 1)
  end

  it "Displays correct dates in phq summary" do
    allow(view).to receive(:tested_weeks) { phq_assessments }
    allow(view).to receive(:test_summary) { { current_week: 1, range_start: 1 } }

    render partial: "think_feel_do_engine/coach/patient_dashboards/phq_summary"

    expect(rendered).to_not have_text "(06/14/2015 - 06/20/2015)"
    expect(rendered).to have_text "(06/15/2015 - 06/21/2015)"
    expect(rendered).to have_text "06/15/2015"
  end
end
