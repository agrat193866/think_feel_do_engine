require "rails_helper"

RSpec.describe "think_feel_do_engine/coach/patient_dashboards/index", type: :view do
  let(:group) { instance_double("Group", title: "Smurf") }
  let(:not_stepped_participants) { double("not stepped participants") }
  let(:stepped_participants) { double("stepped participants") }
  let(:participants) do
    double("all participants",
           not_stepped: not_stepped_participants,
           stepped: stepped_participants)
  end

  before do
    assign(:group, group)
    assign(:participants, participants)
  end

  it "renders the title" do
    allow(view).to receive(:phq_features?) { true }

    render

    expect(rendered).to have_text "Smurf Patient Dashboard"
  end

  it "renders a link to the group" do
    allow(view).to receive(:phq_features?) { true }

    render

    expect(rendered).to have_link "Group", "#"
  end

  context "when phq features are enabled" do
    it "renders the Stepped and Not Stepped headers" do
      allow(view).to receive(:phq_features?) { true }

      render

      expect(rendered).to match(/>Not Stepped Patients</)
      expect(rendered).to match(/>Stepped Patients</)
    end
  end

  context "when phq features are disabled" do
    it "does not render the Not Stepped header" do
      allow(view).to receive(:phq_features?) { false }

      render

      expect(rendered).not_to match(/>Not Stepped Patients</)
      expect(rendered).not_to match(/>Stepped Patients</)
    end
  end
end
