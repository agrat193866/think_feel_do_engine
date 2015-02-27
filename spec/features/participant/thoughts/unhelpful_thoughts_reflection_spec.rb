require "rails_helper"

feature "Thoughts", type: :feature do
  fixtures :all

  describe "When in Think #2 Reshape" do
    describe "ContentProvider::UnhelpfulThoughtsReflectionProvider", :js do
      let(:participant1) { participants(:participant1) }

      before :each do
        sign_in_participant participant1
        visit "/navigator/modules/#{ bit_core_content_modules(:think_reshape).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:think_reshape_unhelpful_thoughts_reflect).id }/1"
      end

      scenario "Participant reviews a harmful thought with pattern" do
        expect(page).to have_text "You said that you thought..."
        expect(page).to have_text "I am useless"
        expect(page).to have_text "Labeling and Mislabeling"
        click_on "Next"
      end
    end
  end
end