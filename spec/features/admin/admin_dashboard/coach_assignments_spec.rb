require "spec_helper"

feature "Coach Assignments and Sensitive Information" do
  fixtures(
    :users, :user_roles, :participants, :coach_assignments
  )

  let(:coach) { users(:user1) }
  let(:assignment1) { coach_assignments(:assignment1) }
  let(:participant1) { participants(:participant1) }
  let(:participant3) { participants(:participant3) }

  before do
    sign_in_user users :admin1
  end

  it "each participant's study is visble, not their email" do
    visit "/admin/coach_assignment"
    expect(page).not_to have_content "participant1@example.com"
    expect(page).to have_content "TFD-1111"
  end

  it "a participant's study id is visible, not email when assigning a patient to a coach" do
    expect(coach.participant_ids.include?(participant3.id)).not_to eq true
    visit "/admin/coach_assignment"
    click_on "Add new"
    select "user1@example.com", from: "Coach"
    expect(page).not_to have_content "participant1@example.com"
    expect(page).not_to have_content "participant3@example.com"
    select "TFD-33303", from: "Participant"
    click_on "Save"
    coach.reload
    expect(coach.participant_ids.include?(participant3.id)).to eq true
  end

  it "display on the a participant's study id when looking at their show page" do
    visit "/admin/coach_assignment/#{assignment1.id}"
    expect(page).not_to have_content "participant1@example.com"
    expect(page).to have_content "TFD-1111"
  end

  it "a participant's study id is visible, not email when editing a patient" do
    expect(coach.participant_ids.include?(participant1.id)).to eq true
    expect(coach.participant_ids.include?(participant3.id)).to eq false
    visit "/admin/coach_assignment/#{assignment1.id}/edit"
    select "user1@example.com", from: "Coach"
    expect(page).not_to have_content "participant1@example.com"
    expect(page).not_to have_content "participant3@example.com"
    select "TFD-33303", from: "Participant"
    click_on "Save"
    coach.reload
    expect(coach.participant_ids.include?(participant1.id)).to eq false
    expect(coach.participant_ids.include?(participant3.id)).to eq true
  end
end
