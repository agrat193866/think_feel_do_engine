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
      (1..10).each { |i| expect(page).to have_text "Week #{i}" }
    end

    it "highlights this week's panel" do
      expect(page).to have_css("div.panel-info", count: 1)
    end

    it "gives style to future weeks" do
      expect(page).to have_css("h3.panel-title.panel-unreleased", count: 7)
    end

    it "opens and displaying this week's lessons" do
      with_scope "div.panel-info" do
        expect(page).to have_css(".lesson.unread", count: 2)
        expect(find("a.task-status")).to have_text "Do - Congrats"
        expect(find("a.task-status")).to have_text "Released Today"
        expect(find("span.task-status")).to have_text "Do - Doing Introduction"
        expect(find("span.task-status")).to have_text(
          "Available on #{ Date.today.advance(days: 4).to_s(:brief_date) }"
        )
      end
    end

    it "can view an assigned learning slideshow that has been released", :js do
      with_scope ".panel-info" do
        expect(find("a.task-status")).to have_text "Do - Congrats"
        expect(find("a.task-status")).to_not have_text(
          "Read on #{ Date.current.to_s(:brief_date) }"
        )

        find("a.task-status").click
      end

      expect(page).to have_text "Good Work!"

      click_on "Continue"

      with_scope ".panel-info" do
        expect(find("a.task-status .read")).to have_text "Do - Congrats"
        expect(find("a.task-status")).to have_text(
          "Read on #{ Date.current.to_s(:brief_date) }"
        )
      end
    end

    it "displays the correct count of unread lessons", :js do
      expect(page).to have_text "Week 3 2"

      click_on "Do - Congrats"
      click_on "Continue"

      expect(page).to have_text "Week 3 1"
    end

    it "displays the correct count of unread lessons for future weeks" do
      expect(page).to have_text "Week 4 1"
    end
  end
end
