require "rails_helper"

RSpec.describe "think_feel_do_engine/messages/show.html.erb", type: :view do
  before do
    allow(view).to receive(:can?).and_return(true)
    allow(view).to receive(:current_user).and_return(double("user"))
    allow(view).to receive(:current_participant)
      .and_return(double("participant", in_study?: true,
                                        coach_assignment: double("coach_assignment"),
                                        active_membership: double("membership")))
    allow(view).to receive(:participant_signed_in?).and_return(true)
    allow(view).to receive(:message).and_return(double("message", sender: double("user", id: 1)))
    allow(view).to receive(:coach_group_messages_path).and_return("coach_group_messages_path")
    allow(view).to receive(:new_coach_group_message_path).and_return("new_coach_group_message_path")
    allow(view).to receive(:compose_path).and_return("compose_path")
    allow(view).to receive(:reply_path).and_return("reply_path")

    stub_template "think_feel_do_engine/messages/_message_info.html.erb" => "This content"
  end

  context "as an authenticated user" do
    it "displays only 1 'Compose' link" do
      render

      expect(rendered).to have_link("Compose", count: 1)
    end
  end
end
