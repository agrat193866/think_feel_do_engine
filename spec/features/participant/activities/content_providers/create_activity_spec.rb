require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Do #1 Awareness" do
    describe "ContentProvider::CreateActivityProvider" do
      let(:participant1) { participants(:participant1) }

      before :each do
        sign_in_participant participant1
        visit "/navigator/modules/#{ bit_core_content_modules(:create_activity).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:create_activity).id }/1"
      end

      scenario "Participant may create a new activity they've already done" do
        choose "activity-title-227206994"
        select 4, from: "activity_predicted_pleasure_intensity"
        select 7, from: "activity_predicted_accomplishment_intensity"
        click_on "Next"

        expect(page).to have_text("Activity saved")
      end

      scenario "Participant may create a new activity they've not yet done" do
        fill_in "planned_activity[activity_type_new_title]", with: "goat herding"
        select 4, from: "activity_predicted_pleasure_intensity"
        select 7, from: "activity_predicted_accomplishment_intensity"
        click_on "Next"

        expect(page).to have_text("Activity saved")
      end
    end
  end
end
