require "rails_helper"

feature "Thoughts", type: :feature do
  fixtures :all

  describe "When in Think #1 Identifying" do
    describe "ContentProvider::NewHarmfulThoughtsFormProvider" do
      let(:participant1) { participants(:participant1) }

      before :each do
        sign_in_participant participant1
        visit "/navigator/modules/#{ bit_core_content_modules(:think_module_distortion_viz).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:thoughts_viz).id }/1"
      end

      scenario "Participant sees a visualization of their thought patterns" do
        expect(page).to have_text("Thought Distortions")
      end
    end
  end
end


