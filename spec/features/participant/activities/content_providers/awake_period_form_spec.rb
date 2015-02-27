require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Do #1 Awareness" do
    describe "ContentProviders::AwakePeriodForm" do
      scenario "Participant reviews awake period from yesterday" do
        sign_in_participant participants(:participant1)
        visit "/navigator/modules/#{ bit_core_content_modules(:do_awareness).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:awake_period_form_provider).id }/1"

        awake_period = awake_periods(:participant1_period1)

        expect(page).to have_content "OK, let's talk about yesterday."
        expect(page).to have_content "Last Recorded Awake Period:"
        expect(page).to have_content "Not Completed"
        expect(page).to have_content(
          "Woke up #{ awake_period.start_time.to_s(:date_time_with_meridian) }"
        )
        expect(page).to have_content(
          "Went to sleep #{ awake_period.end_time.to_s(:date_time_with_meridian) }"
        )

        click_on "Complete"

        expect(page).not_to have_content "Last Recorded Awake Period:"
      end

      scenario "Participant creates awake period times from yesterday" do
        sign_in_participant participants(:participant4)
        visit "/navigator/modules/#{ bit_core_content_modules(:do_awareness).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:awake_period_form_provider).id }/1"

        expect(page).to have_content "OK, let's talk about yesterday."

        select Time.now.strftime("%a") + " 1 AM", from: "About what time did you wake up?"
        select Time.now.strftime("%a") + " 5 AM", from: "About what time did you go to sleep? This doesn't need to be exact either."
        click_on "Create"

        expect(page).not_to have_content "what time did you wake up?"
      end
    end
  end
end
