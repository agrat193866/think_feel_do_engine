require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Do #1 Awareness" do
    describe "ContentProvider::PastActivityFormProvider" do
      scenario "Participant records activities for a day", :js do
        sign_in_participant participants(:participant1)
        visit "/navigator/modules/#{ bit_core_content_modules(:do_awareness).id }" \
                  "/providers/" \
              "#{ bit_core_content_providers(:past_activity_form_provider).id }/1"

        expect(page).to have_text "Review Your Day"

        fill_in "activity_type_0", with: "ate cheeseburgers"
        choose_rating("pleasure_0", 9)
        choose_rating("accomplishment_0", 4)
        fill_in "activity_type_1", with: "ate bad cheeseburgers"
        choose_rating("pleasure_1", 0)
        choose_rating("accomplishment_1", 9)
        find("#copy_2").trigger("click")
        click_on "Next"

        expect(page).to have_text "ate cheeseburgers"
        expect(page).to have_text "ate bad cheeseburgers", count: 2
      end
    end
  end
end