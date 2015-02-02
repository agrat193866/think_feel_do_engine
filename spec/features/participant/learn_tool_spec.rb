require "spec_helper"

feature "learn tool", type: :feature do
  fixtures :all

  context "participant logged in and visits LEARN index page" do
    before do
      sign_in_participant participants(:participant_for_learning)
      visit "/navigator/contexts/LEARN"
    end

    it "displays a heading" do
      expect(page).to have_text "Lessons Week 3"
    end

    it "displays all 10 weeks" do
      (1..10).each { |i| expect(page).to have_text "Week #{i}" }
    end

    it "highlights this week's panel" do
      expect(page).to have_css("div.panel-info", count: 1)
    end

    it "gives style to future weeks" do
      expect(page).to have_css("h3.panel-title.panel-unreleased", count: 7)
    end

    it "opens and displaying this week's lessons" do
      within "div.panel-info" do
        expect(page).to have_css(".lesson.unread", count: 2)
        expect(find(".task-status.enabled")).to have_text "Do - Congrats"
        expect(find(".task-status.enabled")).to have_text "Released Today"
        expect(find(".task-status.disabled")).to have_text "Do - Doing Introduction"
        expect(find(".task-status.disabled")).to have_text(
          "Available on #{ Date.today.advance(days: 4).to_s(:brief_date) }"
        )
      end
    end

    it "orders lessons by module position" do
      lesson_titles = all("div.panel-info .lesson > p")

      expect(lesson_titles[0]).to have_text "Do - Doing Introduction"
      expect(lesson_titles[1]).to have_text "Do - Congrats"
    end

    it "can view an assigned learning slideshow that has been released", :js do
      within ".panel-info" do
        expect(find(".task-status.enabled")).to have_text "Do - Congrats"
        expect(find(".task-status.enabled")).to_not have_text(
          "Read on #{ Date.current.to_s(:brief_date) }"
        )

        find(".enabled .task-status").click
      end

      expect(page).to have_text "Good Work!"

      click_on "Finish"

      within ".panel-info" do
        expect(find(".task-status.enabled .read")).to have_text "Do - Congrats"
        expect(find(".task-status.enabled")).to have_text(
          "Read on #{ Date.current.to_s(:brief_date) }"
        )
      end
    end

    it "displays the correct count of unread lessons", :js do
      date = Date.current.advance(days: -2)
      expect(page).to have_text "Week 3 · #{ date.to_s(:brief_date) } 2"

      click_on "Do - Congrats"
      click_on "Finish"

      expect(page).to have_text "Week 3 · #{ date.to_s(:brief_date) } 1"
    end

    it "displays the correct count of unread lessons for future weeks" do
      date = Date.current.advance(days: 5)
      expect(page).to have_text "Week 4 · #{ date.to_s(:brief_date) } 1"
    end

    it "allows viewing printable page for read lessons" do
      click_on "Printable"

      expect(page).to have_text "Do - Planning Introduction"
      expect(page).to have_link "Print"
    end
  end
end
