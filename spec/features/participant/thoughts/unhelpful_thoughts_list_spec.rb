require "rails_helper"

feature "Thoughts", type: :feature do
  fixtures :all

  describe "When in Think #2 Reshape" do
    describe "ContentProvider::UnhelpfulThoughtsListProvider" do
      let(:participant1) { participants(:participant1) }

      before :each do
        sign_in_participant participant1
        visit "/navigator/modules/#{ bit_core_content_modules(:think_reshape).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:think_reshape_unhelpful_thoughts_list).id }/1"
      end

      scenario "Participant reviews harmful thoughts" do
        expect(page).to have_text "I am useless"
        expect(page).to have_text "I am insignificant"
        expect(page).to have_text "ARG!"
        click_on "Next"
      end
    end
  end
end