require "spec_helper"

feature "learn tool", type: :feature do
  fixtures(
    :arms, :participants, :"bit_core/slideshows", :"bit_core/slides", :users,
    :"bit_core/tools", :"bit_core/content_modules", :"bit_core/content_providers",
    :groups, :memberships, :tasks, :task_status
  )

  context "participant logged in and visits LEARN index page" do
    before do
      sign_in_participant participants(:participant_for_learning)
      visit "/navigator/contexts/LEARN"
    end

    it "displays a heading" do
      expect(page).to have_text "Lessons Week 3"
    end

    it "displays all 10 weeks" do
      i = 1
      while i < 11
        expect(page).to have_text "Week #{i}"
        i += 1
      end
    end

    it "highlights this week's panel" do
      expect(page).to have_css("div.panel-info", count: 1)
    end

    it "gives style to future weeks" do
      expect(page).to have_css("h3.panel-title.panel-unreleased", count: 7)
    end

    it "opens and displaying this week's lessons" do
      with_scope "div.panel-info" do
        expect(page).to have_link "Do - Congratulations Unread"
        expect(page).to have_text "Released Today"
        expect(page).to have_link "Do - Doing Introduction Unread"
        expect(page).to have_text "Available on #{ Date.today.advance(days: 4).to_s(:brief_date) }"
      end
    end

    it "disabled lessons can't be clicked", :js do
      expect(page.body).to have_css("a.disabled", count: 2)
      expect(page).to have_link "Do - Doing Introduction Unread"
      expect(page).to have_text "Available on #{ Date.today.advance(days: 4).to_s(:brief_date) }"

      click_on "Do - Doing Introduction Unread"

      expect(current_path).to eq "/navigator/contexts/LEARN"
      expect(page).to have_link "Do - Doing Introduction Unread"
    end

    it "can view an assigned learning slideshow that has been released", :js do
      expect(page).to have_link "Do - Congratulations Unread"
      expect(page).to_not have_text "Read on #{ Date.current.to_s(:brief_date) }"

      click_on "Do - Congratulations"

      expect(page).to have_text "Good Work!"

      click_on "Continue"

      expect(page).to have_link "Do - Congratulations Read"
      expect(page).to have_text "Read on #{ Date.current.to_s(:brief_date) }"
    end

    it "displays the correct count of unread lessons", :js do
      expect(page).to have_text("Week 3 2")

      click_on "Do - Congratulations"
      click_on "Continue"

      expect(page).to have_text("Week 3 1")
    end
  end
end
