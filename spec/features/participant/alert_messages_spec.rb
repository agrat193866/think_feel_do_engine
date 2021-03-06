require "rails_helper"

feature "alert messages", type: :feature do
  fixtures :arms, :participants, :users, :groups, :memberships

  before do
    sign_in_participant participants(:inactive_participant)
  end

  it "are visible when a user isn't assigned to a group" do
    expect(page).to have_text "We're sorry, but you can't sign in yet because you are not assigned to an active group."
  end
end
