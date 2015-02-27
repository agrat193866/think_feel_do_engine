require "rails_helper"

feature "Thoughts", type: :feature do
  fixtures :all

  describe "When in Think #1 Identifying" do
    describe "ContentProvider::NewThoughtsFormProvider" do
      let(:participant1) { participants(:participant1) }

      before :each do
        sign_in_participant participant1
        visit "/navigator/modules/#{ bit_core_content_modules(:think_identifying).id }" \
              "/providers/" \
              "#{ bit_core_content_providers(:think_identify_new_thoughts_form).id }/1"
      end

      scenario "Participant identifies an additional harmful thought" do
        expect(page).to have_text "Now list another harmful thought..."
        fill_in "thought[content]", with: "I will never ever get all my specs to pass."
        click_on "Next"
      end
    end
  end
end