require "rails_helper"

feature "Thoughts", type: :feature do
  fixtures :all

  describe "When in Think #2 Patterns" do
    describe "ContentProvider::HarmfulThoughtsEditFormProvider" do
      let(:participant) { participants(:participant4) }

      before do
        sign_in_participant participant
      end

      scenario "Participant reviews a harmful thought pattern", :js do
        visit "/navigator/modules/#{ bit_core_content_modules(:think_identifying).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:think_identify_new_harmful_thought_form).id }/1"
        expect(page).to have_text "Just one more harmful thought and you'll be done for now..."
        fill_in "thought[content]", with: "I will never ever ever get all my specs to pass."
        click_on "Next"

        visit "/navigator/modules/#{ bit_core_content_modules(:think_patterns).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:think_harmful_thoughts_form).id }/1"

        expect(page).to have_text "One thought you had:"
        expect(page).to have_text "I will never ever ever get all my specs to pass"
        select("Overgeneralization", from: "What thought pattern is this an example of?")
        sleep(2.seconds)
        click_on "Next"
        expect(page).to have_text "Thought saved"
      end
    end
  end
end