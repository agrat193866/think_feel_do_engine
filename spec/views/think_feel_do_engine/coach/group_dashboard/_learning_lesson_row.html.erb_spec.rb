require "rails_helper"

RSpec.describe "think_feel_do_engine/coach/group_dashboard/_learning_lesson_row.html.erb",
               type: :view do
  fixtures :all

  let(:provider) { double("bit_core_content_provider") }

  before do
    allow(provider).to receive_message_chain(:source_content, :title) { "**TEST**" }
    allow(view).to receive(:content_provider) { provider }
    allow(view).to receive(:task) do
      double(
        "task",
        total_read: 0,
        total_assigned: 0,
        id: 0,
        group: double("group"),
        complete_participant_list: [],
        incomplete_participant_list: [])
    end
  end

  it "includes " do
    render partial: "think_feel_do_engine/coach/group_dashboard/learning_lesson_row"

    expect(rendered).to match(/TEST/)
    expect(rendered).not_to match(/\*\*TEST\*\*/)
  end
end