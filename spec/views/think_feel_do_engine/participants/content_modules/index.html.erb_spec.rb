require "rails_helper"

RSpec.describe "think_feel_do_engine/participants/content_modules/index",
               type: :view do
  describe "AvailableContentModules exist" do
    let(:membership) { instance_double(Membership) }
    let(:didactic_module) do
      instance_double(
        AvailableContentModule,
        title: "foo",
        id: 1,
        task_status_id: 1)
    end
    let(:non_didactic_module) do
      instance_double(
        AvailableContentModule,
        title: "bar",
        id: 1,
        task_status_id: 1)
    end
    let(:task_status) do
      instance_double(
        TaskStatus,
        completed_at: "some time")
    end
    let(:tool) do
      instance_double(
        BitCore::Tool,
        description: "Hammer time")
    end

    before do
      allow(view)
        .to receive_message_chain("content_modules.is_viz") { [] }
      allow(view)
        .to receive_message_chain("content_modules.first.bit_core_tool") { tool }
      allow(membership)
        .to receive_message_chain("available_task_statuses.for_content_module.order.last")
        .and_return(task_status)
      render template: "think_feel_do_engine/participants/content_modules/index",
             locals: {
               didactic_modules: [didactic_module],
               non_didactic_modules: [non_didactic_module],
               membership: membership
             }
    end

    it "populates the tool_description" do
      expect(view.content_for(:tool_description)).to eq "Hammer time"
    end

    it "populates the left panel with correct link text" do
      expect(view.content_for(:left)).to have_text "foo"
    end

    it "populates the right panel with correct link text" do
      expect(view.content_for(:right)).to have_text "bar"
    end
  end
end
