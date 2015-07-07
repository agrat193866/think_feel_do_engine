require "rails_helper"

RSpec.describe "think_feel_do_engine/manage/groups/_assigned_task_cell.html.erb",
               type: :view do
  let(:title) { "Pretty Markdown" }
  let(:task) do
    double(
      "task",
      id: 1,
      title: title
      )
  end

  before do
    allow(view).to receive(:task) { task }
    allow(view).to receive(:arm_bit_maker_content_module_path) { "" }
    allow(task).to receive_message_chain(:group, :arm) { "" }
    allow(task).to receive_message_chain(:bit_core_content_module, :tool, :title) { "" }
  end

  it "renders task content title as content author" do
    allow(view).to receive_message_chain(:current_user, :content_author?) { true }
    render partial: "think_feel_do_engine/manage/groups/assigned_task_cell"
    expect(rendered).to have_css(".task_title_cell .author_title", count: 1, text: title)
  end

  it "renders task content title when not content author" do
    allow(view).to receive_message_chain(:current_user, :content_author?) { false }
    render partial: "think_feel_do_engine/manage/groups/assigned_task_cell"
    expect(rendered).to have_css(".task_title_cell", count: 1, text: title)
  end
end