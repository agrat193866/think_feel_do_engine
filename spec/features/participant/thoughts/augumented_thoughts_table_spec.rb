require "rails_helper"

feature "Thoughts", type: :feature do
  fixtures :all

  describe "When in Think Add A New Harmful Thought" do
    describe "ContentProvider::ContentProviders::AugmentedThoughtsTableProvider" do
      let(:participant1) { participants(:participant1) }

      before :each do
        sign_in_participant participant1
        visit "/navigator/modules/#{ bit_core_content_modules(:think_module_thoughts_table).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:thoughts_table_augmented).id }/1"
      end

      scenario "Participant reviews a list of harmful thoughts with challenges", :js do
        expect(page).to have_text "Harmful Thoughts"
        expect(page).to have_text "ARG!"
        expect(page).to have_text "I am a magnet for birds"
        expect(page).to have_text "Labeling and Mislabeling"
        expect(page).to have_text "I am a magnet for birds"
        expect(page).to have_text "It was nature"
        expect(page).to have_text "Birds have no idea what they are doing"
      end

      scenario "Participant may edit a harmful thought", :js do
        click_on "Edit Thoughts"
        fill_in "thoughts_883344735_content", with: "ARG! BARGH!"
        find(:xpath, '//*[@id="thought-883344735"]/td[6]/input').click
        expect(page).to have_text "ARG! BARGH!"
      end
    end
  end
end
