require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Do Activities" do
    describe "ContentProviders::PastDueActivitiesViz" do
      let(:participant) { participants(:participant1) }
      let(:upcoming_activity) do
        Activity.new(
          participant: participant,
          activity_type: activity_types(:going_for_a_walk),
          predicted_pleasure_intensity: 6,
          predicted_accomplishment_intensity: 4,
          start_time: DateTime.current.advance(hours: 2),
          end_time: DateTime.current.advance(hours: 3)
        )
      end
      let(:past_activity) do
        Activity.new(
          participant: participant,
          activity_type: activity_types(:hanging_with_friends),
          predicted_pleasure_intensity: 9,
          predicted_accomplishment_intensity: 4,
          start_time: DateTime.current.advance(hours: -12),
          end_time: DateTime.current.advance(hours: -11)
        )
      end

      scenario "Participant views Upcoming and Recent Past Activities" do
        sign_in_participant participant
        visit "/navigator/modules/#{ bit_core_content_modules(:do_past_due_activities).id }" \
                  "/providers/" \
              "#{ bit_core_content_providers(:do_past_due_activities).id }/1"
        expect(page).to_not have_the_table(
          id: "table-Upcoming_Activities",
          cells: [
            "Going for a walk",
            "#{upcoming_activity.start_time.to_s(:standard)}",
            "Kind of fun (6)",
            "Average Importance (4)"
          ]
        )
        expect(page).to_not have_the_table(
          id: "table-Upcoming_Activities",
          cells: [
            "Hanging with friends",
            "#{past_activity.start_time.to_s(:standard)}",
            "Really fun (9)",
            "Average Importance (4)"
          ]
        )

        past_activity.save
        upcoming_activity.save
        visit "/navigator/modules/#{ bit_core_content_modules(:do_past_due_activities).id }" \
                  "/providers/" \
              "#{ bit_core_content_providers(:do_past_due_activities).id }/1"
        expect(page).to have_text("Upcoming Activities")
        expect(page).to have_text("Going for a walk")
        expect(page).to have_text("#{ upcoming_activity.start_time.to_s(:standard) }")
        expect(page).to have_text("Kind of fun (6)")
        expect(page).to have_text("Average Importance (4)")

        expect(page).to have_text("Recent Past Activities")
        expect(page).to have_text("Hanging with friends")
        expect(page).to have_text("#{ past_activity.start_time.to_s(:standard) }")
        expect(page).to have_text("Really fun (9)")
        expect(page).to have_text("Average Importance (4)")
      end
    end
  end
end