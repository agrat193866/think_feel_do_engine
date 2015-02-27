require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Do #2 Planning" do
    describe "ContentProvider::FunActivityChecklist" do
      scenario "Participant plans an activity", :js do
        sign_in_participant participants(:participant1)
        visit "/navigator/modules/#{ bit_core_content_modules(:do_planning).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:do_planning_fun_activity_checklist).id }/1"

        expect(page).to have_text "We want you to plan one fun thing"
        find("input[value='Loving'][type='radio']").click
        fill_in "future_date_picker_0", with: Date.today + 1.day
        choose_rating "pleasure_0", 10
        select 9, from: "How much pleasure did you expect to get from doing this?"
        select 9, from: "How much accomplishment do you expect to get from doing this?"
        click_on "Next"

        expect(page).to have_text("Now, plan something that gives you a sense of accomplishment.")
      end
    end
  end
end
