require "rails_helper"

feature "Slideshow", type: :feature do
  urls = ThinkFeelDoEngine::Engine.routes.url_helpers

  fixtures :all

  context "Logged in as a content author" do
    before do
      sign_in_user users :content_author1
      visit "/arms/#{arms(:arm1).id}/bit_maker/slideshows"
    end

    it "have a corresponding show page that displays the title" do
      click_on "Home Introduction"
      slideshow = BitCore::Slideshow.find_by_title("Home Introduction")

      expect(current_path).to eq urls.arm_bit_maker_slideshow_path(arms(:arm1), slideshow)
      expect(page).to have_text("Home Introduction")
    end

    describe "managing groups by assigning modules and setting release days" do
      it "isn't performed if a title isn't provided and a flash messages displays this error" do
        slideshow = BitCore::Slideshow.find_by_title("Home Introduction")
        within "#slideshow-#{slideshow.id}" do
          click_on "Edit"
        end
        fill_in "Title", with: ""
        click_on "Update"

        expect(page).to have_text("Title can't be blank")
        slideshow.reload

        expect(slideshow.title).not_to eq ""
        expect(slideshow.title).to eq "Home Introduction"
      end
    end

    it "be deleted and no longer visible" do
      expect(page).to have_text("Home Introduction")
      expect(BitCore::Slideshow.find_by_title("Home Introduction")).not_to eq nil

      slideshow = BitCore::Slideshow.find_by_title("Home Introduction")
      within "#slideshow-#{slideshow.id}" do
        click_on "Delete"
      end

      expect(BitCore::Slideshow.find_by_title("Home Introduction")).to eq nil
      expect(page).to_not have_text("Home Introduction")
    end

    it "should scope slideshows to arm when on index" do
      visit "/arms/#{arms(:arm1).id}/bit_maker/slideshows"

      expect(page).to have_content "Home Intro"
      expect(page).to_not have_content "HOME Intro ARM@"

      visit "/arms/#{arms(:arm2).id}/bit_maker/slideshows"

      expect(page).to_not have_content "Home Intro"
      expect(page).to have_content "HOME Intro ARM@"
    end
  end
end
