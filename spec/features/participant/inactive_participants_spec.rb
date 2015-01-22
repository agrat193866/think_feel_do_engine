require "spec_helper"

feature "reset user password", type: :feature do
  fixtures :all

  let(:participant) { participants(:inactive_participant) }

  before { clear_emails }

  it "should not allow participant to log back in after updating a forgotten password" do
    token = participant.send_reset_password_instructions
    visit "/participants/password/edit?reset_password_token=#{token}"
    fill_in "New password", with: "dog pig cat yeah!"
    fill_in "Confirm new password", with: "dog pig cat yeah!"
    click_on "Change my password"

    expect(current_path).to eq "/participants/sign_in"
    expect(page).to have_content "We're sorry, but you can't sign in yet because you are not assigned to an active group."
  end
end
