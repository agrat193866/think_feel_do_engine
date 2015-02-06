require "rails_helper"

feature "Slide", type: :feature do
  urls = ThinkFeelDoEngine::Engine.routes.url_helpers

  fixtures :arms, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides"

  context "Logged in as a content author" do
    before do
      sign_in_user users :content_author1
      visit urls.arm_bit_maker_slideshow_path(arms(:arm1), bit_core_slideshows(:home_intro))
    end

    describe "creating" do
      it "display title and body upon creation", :js do
        expect(current_path).to eq urls.arm_bit_maker_slideshow_path(arms(:arm1), bit_core_slideshows(:home_intro))
        expect(page).to_not have_text("A great slide!!")
        click_on "Add Slide"
        fill_in "Title", with: "A great slide!!"
        fill_in "Body", with: "The greatest content ever! 100% = 14/14 + 00.00"
        click_on "Create"
        expect(current_path).to eq urls.arm_bit_maker_slideshow_path(arms(:arm1), bit_core_slideshows(:home_intro))
        expect(page).to have_text("A great slide!!")
        click_on "A great slide!!"
        expect(page).to have_text("The greatest content ever! 100% = 14/14 + 00.00")
      end

      it "not be created if no title is provided and will display error" do
        click_on "Add Slide"
        fill_in "Title", with: ""
        click_on "Create"
        expect(page).to have_text("Title can't be blank")
      end
    end

    describe "Updating" do
      it "display updated title and body" do
        slide = BitCore::Slide.find_by_title("It's simple.")
        within "#slide_#{slide.id}" do
          click_on "Edit"
        end
        fill_in "Title", with: "This is no longer home, it is..."
        fill_in "Body", with: "BIG BODY!"
        click_on "Update"
        slide.reload
        expect(slide.title).not_to eq "It's simple."
        expect(slide.title).to eq "This is no longer home, it is..."
        expect(slide.body).not_to eq "I'm serious!"
        expect(slide.body).to eq "BIG BODY!"
        expect(current_path).to eq urls.arm_bit_maker_slideshow_path(arms(:arm1), bit_core_slideshows(:home_intro))
      end

      it "not be updated if the slide doesn't have a title or body" do
        slide = BitCore::Slide.find_by_title("It's simple.")
        within "#slide_#{slide.id}" do
          click_on "Edit"
        end
        fill_in "Title", with: ""
        fill_in "Body", with: ""
        click_on "Update"
        expect(page).to have_text("Title can't be blank")
        slide.reload
        expect(slide.title).not_to eq ""
        expect(slide.body).not_to eq ""
        expect(slide.title).to eq "It's simple."
      end

      it "display title if the visibility is set or the title should be hidden if option is not selected" do
        slide = BitCore::Slide.find_by_title("It's simple.")
        click_on "It's simple."
        expect(page).to have_text "It's simple."
        visit urls.arm_bit_maker_slideshow_path(arms(:arm1), bit_core_slideshows(:home_intro))
        within "#slide_#{slide.id}" do
          click_on "Edit"
        end
        uncheck "Display Title For Slide"
        click_on "Update"
        click_on "It's simple."
        expect(page).to_not have_text "It's simple."
        visit urls.arm_bit_maker_slideshow_path(arms(:arm1), bit_core_slideshows(:home_intro))
        within "#slide_#{slide.id}" do
          click_on "Edit"
        end
        check "Display Title For Slide"
        click_on "Update"
        click_on "It's simple."
        expect(page).to have_text "It's simple."
      end
    end

    it "no longer exists or is visible" do
      expect(page).to have_text("It's simple.")
      slide = BitCore::Slide.find_by_title("It's simple.")
      expect(slide).not_to eq nil
      within "#slide_#{slide.id}" do
        click_on "Remove"
      end
      expect(BitCore::Slide.find_by_title("It's simple.")).to eq nil
      expect(page).not_to have_text("It's simple.")
    end
  end
end
