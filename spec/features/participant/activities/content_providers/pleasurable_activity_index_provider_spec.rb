require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Do #1 Awareness" do
    describe "ContentProvider::AccomplishedActivityIndexProvider" do
      let(:participant1) { participants(:participant1) }

      before :each do
        AwakePeriod.create(
          start_time: DateTime.current.advance(hours: -30),
          end_time: DateTime.current.advance(hours: -20),
          participant: participant1)
        Activity.create(
          activity_type: activity_types(:arguing_with_my_boss),
          actual_pleasure_intensity: 9,
          actual_accomplishment_intensity: 0,
          participant: participant1,
          start_time: DateTime.current.advance(hours: -26),
          end_time: DateTime.current.advance(hours: -25))
        Activity.create(
          activity_type: activity_types(:eating),
          actual_pleasure_intensity: 0,
          actual_accomplishment_intensity: 9,
          participant: participant1,
          start_time: DateTime.current.advance(hours: -26),
          end_time: DateTime.current.advance(hours: -25))
      end

      scenario "Participant with pleasureable activities views accomplished activities index" do
        sign_in_participant participant1
        visit "/navigator/modules/#{ bit_core_content_modules(:do_awareness).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:pleasurable_activity_index).id }/1"

        expect(page).to have_text("Arguing with my boss")
        expect(page).not_to have_text("Eating breakfast")
      end
    end
  end
end