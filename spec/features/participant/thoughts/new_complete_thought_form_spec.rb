require "rails_helper"

feature "Thoughts", type: :feature do
  fixtures :all

  describe "When in Think Add A New Harmful Thought" do
    describe "ContentProvider::NewCompleteThoughtFormProvider" do
      let(:participant1) { participants(:participant1) }

      before :each do
        sign_in_participant participant1
        visit "/navigator/modules/#{ bit_core_content_modules(:think_module5).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:thought_add_complete).id }/1"
      end

      scenario "Participant identifies a new harmful thought" do
        expect(page).to have_text "Add a New Harmful Thought"
        fill_in "thought[content]", with: "I will never get all my specs to pass."
        select "Labeling", from: "thought[pattern_id]"
        fill_in "thought_challenging_thought", with: "I got that other spec to pass."
        fill_in "thought_act_as_if", with: "I will keep working on this spec."
        click_on "Next"
        expect(page).to have_text("Thought saved")
      end
    end
  end
end