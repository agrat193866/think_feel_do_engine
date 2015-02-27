require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Do #2 Planning" do
    describe "ContentProviders::UnplannedActivityForm" do
      scenario "Participant reviews planned activities" do
        sign_in_participant participants(:participant4)
        visit "/navigator/modules/#{ bit_core_content_modules(:do_planning).id }" \
                  "/providers/" \
                  "#{ bit_core_content_providers(:planned_activities_provider).id }/1"

        expect(page).to have_text("Your Planned Activities")
        expect(page).to have_text("Commuting")

        click_on "Next"

        expect(page).to have_text("Do landing")
      end
    end
  end
end