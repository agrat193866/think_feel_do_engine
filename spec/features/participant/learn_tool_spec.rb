require "spec_helper"

feature "learn tool", type: :feature do
  fixtures(
    :arms, :participants, :"bit_core/slideshows", :"bit_core/slides", :users,
    :"bit_core/tools", :"bit_core/content_modules", :"bit_core/content_providers",
    :groups, :memberships, :tasks, :task_status
  )

  context "participant who has one lesson" do
    before do
      sign_in_participant participants(:participant1)
      visit "/navigator/contexts/LEARN"
    end

    it "can view assigned slideshow that are released", :js do
      expect(page).to have_link("Do - Awareness Introduction")

      click_on "Do - Planning Introduction"
      expect(page.body).to have_css("a.disabled", count: 1)

      expect(current_path).to eq "/navigator/contexts/LEARN"
      page.find(".list-group-item.task-status:first-child").trigger("click")
      content_module = bit_core_content_modules(:slideshow_content_module_2)
      provider = bit_core_content_providers(:content_provider_slideshow_2)
      expect(page).to have_text("LEARN", count: 2)
      expect(page).to have_text("This is just the beginning...")
      expect(current_path).to eq "/navigator/modules/#{content_module.id}/providers/#{provider.id}/1"
      expect(page).to have_text("Do - Awareness Introduction")

      visit "/navigator/contexts/LEARN"
      expect(page).to have_text "Available on #{ Date.current.to_s(:brief_date) }"
    end
  end

  context "participant with multiple lessons" do
    before do
      sign_in_participant participants(:participant2)
      visit "/navigator/contexts/LEARN"
    end

    it "highlights the current week's panel" do
      expect(page).to have_css("div.panel-info", count: 1)
    end

    it "displays assigned slideshows (with the correct slides) based on released day" do
      expect(page).to have_text("Week 1 2")
      expect(page).to have_link("Do - Awareness Introduction")
      expect(page).to have_text "Available on #{ Date.current.to_s(:brief_date) }"
      expect(page).to have_link("Do - Planning Introduction")
      expect(page).to have_text "Released on #{ Date.current.advance(days: -1).to_s(:brief_date) }"
      expect(page).to have_selector(".list-group-item.task-status:last-child", text: "Do - Planning Introduction")
      page.find(".list-group-item.task-status:last-child").click
      expect(page).to have_text("LEARN")
      expect(page).to have_text("Do - Planning Introduction")
      expect(page).to have_text("The last few times you were here...")
    end

    it "displays unread notification and the correct count of lessons", :js do
      expect(page).to have_text("Week 1 2")
      page.find("p", text: "Do - Awareness Introduction").trigger("click")
      visit "/navigator/contexts/LEARN"
      expect(page).to have_text("Week 1 1")
    end
  end
end
