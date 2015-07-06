require "rails_helper"

RSpec.describe "think_feel_do_engine/coach/group_dashboard/_learning_lesson_row.html.erb",
               type: :view do
  let(:lesson_module) { double("bit_core_lesson_module") }

  before do
    allow(view).to receive_message_chain(:content_provider, :source_content) { lesson_module }
    allow(lesson_module).to receive(:pretty_title) { "Pretty Markdown" }
    stub_template "think_feel_do_engine/coach/group_dashboard/_lesson_completion_breakdown" => ""
    allow(view).to receive(:task) { nil }
  end

  it "runs the method `pretty_title`" do
    expect(lesson_module).to receive(:pretty_title) { true }
    render partial: "think_feel_do_engine/coach/group_dashboard/learning_lesson_row"
  end
end
