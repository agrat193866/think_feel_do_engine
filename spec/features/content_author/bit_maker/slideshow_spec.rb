require "spec_helper"

feature "Slideshow", type: :feature do
  urls = ThinkFeelDoEngine::Engine.routes.url_helpers

  fixtures(
    :arms, :participants, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships,
    :tasks, :task_status
  )

  before do
    sign_in_user users :admin1
    visit "/arms/#{arms(:arm1).id}/bit_maker/slideshows"
  end

  it "have a corresponding show page that displays the title" do
    click_on "Home Introduction"
    slideshow = BitCore::Slideshow.find_by_title("Home Introduction")
    expect(current_path).to eq urls.arm_bit_maker_slideshow_path(arms(:arm1), slideshow)
    expect(page).to have_text("Home Introduction")
  end

  describe "updating" do
    it "shows updated slideshow's title and the change is reflected in all corresponding views" do
      slideshow = BitCore::Slideshow.find_by_title("Do - Awareness Introduction")
      expect(page).to have_text "Do - Awareness Introduction"
      expect(page).to_not have_text "Updated Title"
      visit "/manage/groups/#{groups(:group1).id}/edit_tasks"
      select "Do - Awareness Introduction", from: "Select Module"
      with_scope ".table" do
        expect(page).to have_text "Do - Awareness Introduction"
        expect(page).to_not have_text "Updated Title"
      end
      visit "/arms/#{arms(:arm1).id}/bit_maker/slideshows"
      with_scope "#slideshow-#{slideshow.id}" do
        click_on "Edit"
      end
      fill_in "Title", with: "Updated Title"
      click_on "Update"
      slideshow.reload
      expect(slideshow.title).not_to eq "Do - Awareness Introduction"
      expect(slideshow.title).to eq "Updated Title"
      expect(current_path).to eq "/arms/#{arms(:arm1).id}/bit_maker/slideshows"
      expect(page).to_not have_text "Do - Awareness Introduction"
      expect(page).to have_text "Updated Title"
      visit "/manage/groups/#{groups(:group1).id}/edit_tasks"
      select "Updated Title", from: "Select Module"
      expect(page).to have_text "Updated Title"
      sign_in_participant participants :participant1
      with_scope "ul#header-navbar.nav.navbar-nav .LEARN.hidden-xs" do
        click_on "LEARN"
      end
      expect(page).not_to have_text "Do - Awareness Introduction"
      expect(page).to have_text "Updated Title"
      click_on "Updated Title"
      expect(page).not_to have_text "Do - Awareness Introduction"
      expect(page).to have_text "Updated Title"
    end

    it "isn't performed if a title isn't provided and a flash messages displays this error" do
      slideshow = BitCore::Slideshow.find_by_title("Home Introduction")
      with_scope "#slideshow-#{slideshow.id}" do
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
    with_scope "#slideshow-#{slideshow.id}" do
      click_on "Delete"
    end
    expect(BitCore::Slideshow.find_by_title("Home Introduction")).to eq nil
    expect(page).to_not have_text("Home Introduction")
  end
end
