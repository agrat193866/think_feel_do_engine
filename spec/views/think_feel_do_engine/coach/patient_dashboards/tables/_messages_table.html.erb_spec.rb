require "rails_helper"

RSpec.describe "think_feel_do_engine/coach/patient_dashboards/tables/" \
               "_messages_table",
               type: :view do
  fixtures :all

  it "links to the participant's messages for the current group" do
    participant = participants(:active_participant)
    assign(:participant, participant)
    assign(:group, participant.groups.first)
    allow(view).to receive(:coach_group_messages_path) { "/some_messages" }
    render partial: "think_feel_do_engine/coach/patient_dashboards/tables/" \
                    "messages_table"

    expect(rendered).to have_link "View", href: "/some_messages"
  end
end
