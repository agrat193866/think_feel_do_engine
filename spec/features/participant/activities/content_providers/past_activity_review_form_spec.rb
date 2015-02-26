require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Do #3 Doing" do
    describe "ContentProvider::PastActivityReviewForm" do
      scenario "Participant reviews an activity they completed" do
        sign_in_participant participants(:participant1)
        visit "/navigator/modules/#{ bit_core_content_modules(:do_doing).id }" \
                  "/providers/" \
              "#{ bit_core_content_providers(:do_doing_past_activity_review).id }/1"

        expect(page).to have_text "You said you were going to Loving"
        choose("activity_is_complete_yes_227206994")
        select 9, from: "activity[actual_accomplishment_intensity]"
        select 4, from: "activity[actual_pleasure_intensity]"
        click_on "Next"
      end

      scenario "Participant reviews an activity they did not complete" do
        sign_in_participant participants(:participant1)
        visit "/navigator/modules/#{ bit_core_content_modules(:do_doing).id }" \
                  "/providers/" \
              "#{ bit_core_content_providers(:do_doing_past_activity_review).id }/1"

        expect(page).to have_text "You said you were going to Loving"
        choose("activity_is_complete_no_227206994")
        fill_in "activity[noncompliance_reason]", with: "ate cheeseburgers instead"
        click_on "Next"
      end
    end
  end
end
