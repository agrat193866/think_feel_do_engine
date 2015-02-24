require "rails_helper"

feature "Thoughts", type: :feature do
  fixtures :all

  describe "When in Think Thoughts" do
    describe "ContentProviders::ThoughtsTableProvider" do
      let(:participant1) { participants(:participant1) }

      before :each do
        sign_in_participant participant1
        visit "/navigator/modules/#{ bit_core_content_modules(:think_module_thoughts_table).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:thoughts_table).id }/1"
      end

      scenario "Participant reviews a list of harmful thoughts with challenges", :js do
        expect(page).to have_text "Harmful Thoughts"
        expect(page).to have_text "Labeling and Mislabeling"
        expect(page).to have_text "I am a magnet for birds"
        expect(page).to have_text "It was nature"
        expect(page).to have_text "Birds have no idea what they are doing"
      end

      scenario "Participant may edit a harmful thought", :js do
        click_on "Edit Thoughts"
        fill_in "thoughts_883344735_content", with: "ARG! BARGH!"
        find(:xpath, '//*[@id="thought-883344735"]/td[6]/input').click
        visit "/"
        visit "/navigator/modules/#{ bit_core_content_modules(:think_module_thoughts_table).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:thoughts_table).id }/1"
        expect(page).to have_text "ARG! BARGH!"
      end

      scenario "Participant may go to add a new thought", :js do
        click_on "Add a New Thought"
        expect(page).to have_text("Add a New Harmful Thought")
      end

      scenario "participant should have a way to updated harmful thought's effect" do
        visit "/navigator/modules/#{bit_core_content_modules(:think_module_thoughts_table).id}"
        click_on "Edit Thoughts"

        expect(page).to_not have_content "Effect"
        expect(page).to_not have_content "harmful"
        expect(page).to_not have_content "helpful"
        expect(page).to_not have_content "neither"
      end
    end
  end
end