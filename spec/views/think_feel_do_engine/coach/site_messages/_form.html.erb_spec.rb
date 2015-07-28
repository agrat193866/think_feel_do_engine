require "rails_helper"

RSpec.describe "think_feel_do_engine/coach/site_messages/_form.html.erb", type: :view do
  before do
    allow(view).to receive(:coach_group_site_messages_path) { "" }
    allow(view).to receive(:host_email_link) { "sloth@ex.co" }
    assign :site_message, SiteMessage.new
    assign :participants, []
  end

  context "as an authenticated user" do
    it "displays host url link" do
      render

      expect(rendered).to have_text("sloth@ex.co")
    end
  end
end
