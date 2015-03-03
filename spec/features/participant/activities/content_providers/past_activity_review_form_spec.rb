require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Do #3 Doing" do
    describe "ContentProvider::PastActivityReviewForm" do
      let(:activity) { activities(:planned_activity0) }

      before :each do
        sign_in_participant participants(:participant1)
        visit "/navigator/modules/#{ bit_core_content_modules(:do_doing).id }" \
                  "/providers/" \
              "#{ bit_core_content_providers(:do_doing_past_activity_review).id }/1"
      end

      scenario "Participant reviews an activity they completed" do
        expect(activity.is_reviewed).to eq false

        choose("activity_is_complete_yes_#{activity.id}")
        select 9, from: "activity[actual_accomplishment_intensity]"
        select 4, from: "activity[actual_pleasure_intensity]"
        click_on "Next"

        expect("Activity Saved")

        activity.reload

        expect(activity.is_reviewed).to eq true
      end

      scenario "Participant reviews an activity they did not complete" do
        expect(activity.is_reviewed).to eq false

        choose("activity_is_complete_no_#{activity.id}")
        fill_in "activity[noncompliance_reason]", with: "ate cheeseburgers instead"
        click_on "Next"

        expect("Activity Saved")

        activity.reload

        expect(activity.is_reviewed).to eq true
      end

      scenario "Participant reviews an activity they did not complete and actual intensities are not set", :js do
        expect(activity.actual_accomplishment_intensity).to be_nil
        expect(activity.actual_pleasure_intensity).to be_nil

        execute_script %{
          $("input#activity_is_complete_no_#{activity.id}").trigger('click');
        }
        fill_in "activity[noncompliance_reason]", with: "ate cheeseburgers instead"

        click_on "Next"

        expect(page).to have_text "Activity saved"
        expect(page).to have_text "Good Work!"

        activity.reload

        expect(activity.actual_accomplishment_intensity).to be_nil
        expect(activity.actual_pleasure_intensity).to be_nil
      end
    end
  end
end
