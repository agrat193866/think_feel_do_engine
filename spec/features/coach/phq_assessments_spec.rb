require "spec_helper"

feature "coach phq assessment management", type: :feature do
  fixtures(
    :users, :user_roles, :participants, :coach_assignments, :phq_assessments
  )

  before do
    sign_in_user users(:user1)
    p1 = participants(:participant1)
    visit "/coach/phq_assessments?participant_id=#{ p1.id }"
  end

  it "should display the participant assessments page" do
    expect(page).to have_content "PHQ assessments for TFD-1111"
  end

  it "should allow for editing an assessment" do
    click_on "Edit"
    click_on "Update Phq assessment"

    expect(page).to have_content "Phq assessment was successfully updated."
  end

  it "should allow for creating an assessment" do
    click_on "New Phq assessment"
    click_on "Create Phq assessment"

    expect(page).to have_content "Phq assessment was successfully created."
  end

  it "should allow for deleting assessments" do
    click_on "Delete"

    expect(page).to have_content "Phq assessment was successfully destroyed."
  end
end
