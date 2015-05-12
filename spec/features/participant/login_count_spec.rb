require "rails_helper"

RSpec.describe "Participant login count", type: :feature do
  fixtures :all

  def participant
    @participant ||= Participant.first
  end

  context "when login occurs through the Sign in form" do
    it "counts the login event" do
      expect { sign_in_participant(participant) }
        .to change { participant.participant_login_events.count }.by(1)
    end
  end
end
