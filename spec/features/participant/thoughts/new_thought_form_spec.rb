require "rails_helper"

feature "Thoughts", type: :feature do
  fixtures :all

  describe "When in Think #1 Identifying" do
    describe "ContentProvider::NewThoughtFormProvider" do
      let(:participant1) { participants(:participant1) }

      before :each do
        sign_in_participant participant1
        visit "/navigator/modules/#{ bit_core_content_modules(:think_identifying).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:think_identify_new_thought_form).id }/1"
      end

      scenario "Participant identifies a new harmful thought" do
        expect(page).to have_text "Try to identify a harmful thought you've had recently"
        fill_in "thought[content]", with: "I will never get all my specs to pass."
        click_on "Next"
      end
    end
  end
end