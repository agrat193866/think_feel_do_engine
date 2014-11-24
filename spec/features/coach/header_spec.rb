require "spec_helper"

feature "header", type: :feature do
  fixtures :users, :user_roles

  it "should display a log out link" do
    sign_in_user users(:user1)

    expect(page).to have_selector("a[href=\"/users/sign_out\"]")
  end
end
