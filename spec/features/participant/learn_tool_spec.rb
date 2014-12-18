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
      expect(page).to have_text("You have read 0 lessons out of 1.")
      expect(page).to have_link("Do - Awareness Introduction")
      expect(page).not_to have_link("Do - Planning Introduction")
      page.find(".list-group-item.task-status:first-child").trigger("click")
      # click_on "Do - Awareness Introduction"
      content_module = bit_core_content_modules(:slideshow_content_module_2)
      provider = bit_core_content_providers(:content_provider_slideshow_2)
      expect(page).to have_text("LEARN", count: 2)
      expect(page).to have_text("This is just the beginning...")
      expect(current_path).to eq "/navigator/modules/#{content_module.id}/providers/#{provider.id}/1"
      expect(page).to have_text("Do - Awareness Introduction")

      visit "/navigator/contexts/LEARN"
      expect(page).to have_text("You have read 1 lesson out of 1.")
    end
  end

  context "participant with multiple lessons" do
    before do
      sign_in_participant participants(:participant2)
      visit "/navigator/contexts/LEARN"
    end

    it "displays assigned slideshows (with the correct slides) based on released day" do
      expect(page).to have_text("You have read 0 lessons out of 2.")
      expect(page).to have_link("Do - Awareness Introduction")
      expect(page).to have_link("Do - Planning Introduction")
      expect(page).to have_selector(".list-group-item.task-status:last-child", text: "Do - Planning Introduction")
      page.find(".list-group-item.task-status:last-child").click
      expect(page).to have_text("LEARN")
      expect(page).to have_text("Do - Planning Introduction")
      expect(page).to have_text("The last few times you were here...")
    end

    it "displays unread notification, the correct count of lessons, and lessons from the past", :js do
      with_scope "#task-status-#{task_status(:task_status7).id}" do
        expect(page).to have_selector("#new_lessons_list a p")
        expect(page).not_to have_text("today's lesson")
      end
      with_scope "#task-status-#{task_status(:task_status8).id}" do
        expect(page).to have_selector("#new_lessons_list a p")
        expect(page).to have_text("today's lesson")
      end
      # click_on "Do - Awareness Introduction"
      page.find("p", text: "Do - Awareness Introduction").trigger("click")
      visit "/navigator/contexts/LEARN"
      with_scope "#task-status-#{task_status(:task_status7).id}" do
        expect(page).not_to have_selector("#new_lessons_list a p")
      end
      with_scope "#task-status-#{task_status(:task_status8).id}" do
        expect(page).to have_selector("#new_lessons_list a p")
      end
    end
  end
end
