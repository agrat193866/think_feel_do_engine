require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Do #2 Planning" do
    let(:participant) { participants(:participant1) }

    before :each do
      Activity.create(
        activity_type: activity_types(:eating),
        actual_pleasure_intensity: 0,
        actual_accomplishment_intensity: 9,
        participant: participant,
        start_time: DateTime.current.advance(hours: -26),
        end_time: DateTime.current.advance(hours: -25))
      sign_in_participant participant
    end

    describe "ContentProvider::ImportantActivityChecklist" do
      describe "Participant plans an activity that gives them accomplishment", :js do
        scenario "by choosing a previously created activity" do
          visit "/navigator/modules/#{ bit_core_content_modules(:do_planning).id }" \
                "/providers/" \
                "#{ bit_core_content_providers(:do_planning_important_activity_checklist).id }/1"
          find("input[value='Eating breakfast'][type='radio']").click
          select 7, from: "How much pleasure did you expect to get from doing this?"
          select 3, from: "How much accomplishment do you expect to get from doing this?"
          click_on "Next"
          visit "/navigator/modules/#{ bit_core_content_modules(:do_planning).id }" \
                    "/providers/" \
                    "#{ bit_core_content_providers(:planned_activities_provider).id }/1"
          expect(page).to have_the_table(
            id: "previous_activities",
            cells: [
              "Eating breakfast",
              "7",
              "3"
            ]
          )
        end

        scenario "by adding a new activity" do
          visit "/navigator/modules/#{ bit_core_content_modules(:do_planning).id }" \
                "/providers/" \
                "#{ bit_core_content_providers(:do_planning_important_activity_checklist).id }/1"
          fill_in "planned_activity[activity_type_new_title]", with: "goat herding"
          select 5, from: "How much pleasure did you expect to get from doing this?"
          select 9, from: "How much accomplishment do you expect to get from doing this?"
          click_on "Next"
          visit "/navigator/modules/#{ bit_core_content_modules(:do_planning).id }" \
                    "/providers/" \
                    "#{ bit_core_content_providers(:planned_activities_provider).id }/1"

          expect(page).to have_the_table(
            id: "previous_activities",
            cells: [
              "goat herding",
              "5",
              "9"
            ]
          )
        end
      end
    end
  end
end
