require "rails_helper"

RSpec.describe "think_feel_do_engine/participants/content_modules/index",
               type: :view do
  fixtures :all

  it "populates the tool_description" do
    tool = BitCore::Tool.where(type: nil).first
    tool.update description: "Hammer time"
    render template: "think_feel_do_engine/participants/content_modules/index",
           locals: {
             content_modules: AvailableContentModule.where(bit_core_tool: tool)
           }

    expect(view.content_for(:tool_description)).to eq "Hammer time"
  end
end
