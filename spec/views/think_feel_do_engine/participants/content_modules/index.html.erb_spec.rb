require "rails_helper"

RSpec.describe "think_feel_do_engine/participants/content_modules/index",
               type: :view do
  fixtures :all

  let(:participant) do
    instance_double(
      Participant,
      active_group: instance_double(Group))
  end

  it "populates the tool_description" do
    allow(view).to receive(:current_participant) { participant }
    allow(view)
      .to receive(:view_membership) { memberships(:membership1) }

    tool = BitCore::Tool.where(type: nil, title: "THOUGHT").first
    tool.update description: "Hammer time"
    render template: "think_feel_do_engine/participants/content_modules/index",
           locals: {
             content_modules: AvailableContentModule.where(bit_core_tool: tool)
           }

    expect(view.content_for(:tool_description)).to eq "Hammer time"
  end
end
