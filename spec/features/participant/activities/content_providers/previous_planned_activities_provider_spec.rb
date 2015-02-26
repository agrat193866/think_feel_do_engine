require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in View Planned Activities" do
    describe "ContentProvider::PreviousPlannedActivitiesProvider" do
      let(:participant) { participants(:participant3) }
      let(:upcoming_activity) do
        Activity.new(
          participant: participant,
          activity_type: activity_types(:sleeping),
          predicted_pleasure_intensity: 1,
          predicted_accomplishment_intensity: 8,
          start_time: DateTime.current.advance(hours: 5),
          end_time: DateTime.current.advance(hours: 6)
        )
      end

      scenario "Participant may create a new activity they've already done" do
        sign_in_participant participant
        visit "/navigator/modules/#{ bit_core_content_modules(:view_planned_activities).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:view_planned_activities).id }/1"

        expect(page).to_not have_the_table(
          id: "previous_activities",
          cells: [
            "Sleeping",
            "#{upcoming_activity.start_time.to_s(:date_time_with_meridian)}",
            "1",
            "8"
          ]
        )

        upcoming_activity.save
        visit "/navigator/modules/#{ bit_core_content_modules(:view_planned_activities).id }" \
                  "/providers/" \
              "#{ bit_core_content_providers(:view_planned_activities).id }/1"

        expect(page).to have_the_table(
          id: "previous_activities",
          cells: [
            "Sleeping",
            "#{upcoming_activity.start_time.to_s(:date_time_with_meridian)}",
            "1",
            "8"
          ]
        )
      end
    end
  end
end