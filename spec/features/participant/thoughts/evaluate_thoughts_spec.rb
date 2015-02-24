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
              "#{ bit_core_content_providers(:think_reshape_evaluate_thoughts_img).id }/1"
      end

      scenario "Participant should see a graphic about thought patterns" do
        expect(page).to have_text("Challenging a thought means evaluating if the thought is accurate.")
        expect(page.find("img")["src"]).to have_content "evaluating_thoughts.gif"
        click_on "Next"
      end
    end
  end
end

