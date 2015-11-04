require "rails_helper"

RSpec.describe "think_feel_do_engine/coach/group_dashboard/_learning_lesson_row.html.erb",
               type: :view do
  let(:title) { "Pretty Markdown" }

  before do
    allow(view).to receive_message_chain(:content_provider, :source_content, :pretty_title) { title }
    stub_template "think_feel_do_engine/coach/group_dashboard/_lesson_completion_breakdown.html.erb" => ""
    allow(view).to receive(:task) { nil }
  end

  it "renders task content title" do
    render partial: "think_feel_do_engine/coach/group_dashboard/learning_lesson_row"
    expect(rendered).to have_css(".learning_lesson_title", count: 1, text: title)
  end
end
