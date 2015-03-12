require "rails_helper"

feature "group dashboard", type: :feature do
  fixtures :all

  describe "Logged in as a clinician" do
    let(:clinician) { users(:clinician1) }
    let(:group1) { groups(:group1) }

    context "Coach views table with many patients" do
      before do
        sign_in_user clinician
        visit "/coach/groups/#{group1.id}/group_dashboard"
      end

      it "should display likes table" do
        expect(page).to have_text("Likes")
      end
    end
  end
end
