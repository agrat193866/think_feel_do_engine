require "rails_helper"

feature "Inactive Participant", type: :feature do
  fixtures :all

  let(:participant) { participants(:inactive_participant) }
  let(:message) { "We're sorry, but you can't sign in yet because you are not assigned to an active group." }

  before { clear_emails }

  it "should not allow participant to log back in after updating a forgotten password" do
    token = participant.send_reset_password_instructions
    visit "/participants/password/edit?reset_password_token=#{token}"
    fill_in "New password", with: "dog pig cat yeah!"
    fill_in "Confirm new password", with: "dog pig cat yeah!"
    click_on "Change my password"

    expect(current_path).to eq "/participants/sign_in"
    expect(page).to have_content message
  end

  describe "Active Participant becoming inactive" do
    let(:active) { participants(:participant1) }

    it "should logout a participant when requesting a route and their membership is no longer active" do
      Timecop.travel(active.active_membership.end_date.end_of_day - 5.minutes) do
        sign_in_participant active
        Timecop.travel(DateTime.current.advance(minutes: 10)) do
          visit "/"

          expect(current_path).to eq "/participants/sign_in"
          expect(page).to have_content message
        end
      end
    end
  end
end
