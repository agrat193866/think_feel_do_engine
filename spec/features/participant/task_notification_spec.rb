require "spec_helper"

feature "task notification", type: :feature do
  fixtures(
    :arms, :users, :user_roles, :participants,
    :"bit_core/slideshows", :"bit_core/slides", :"bit_core/tools",
    :"bit_core/content_modules", :"bit_core/content_providers",
    :groups, :memberships, :tasks, :task_status
  )

  let(:ts1) { task_status(:task_status1) }
  let(:ts1_module) { ts1.task.bit_core_content_module }
  let(:ts2) { task_status(:task_status2) }
  let(:ts2_module) { ts2.task.bit_core_content_module }
  let(:learning_ts) { task_status(:task_status3) }
  let(:learning_ts_module) { learning_ts.task.bit_core_content_module }
  let(:learning_ts_provider) { learning_ts_module.content_providers.last }

  let(:unassigned_module) do
    BitCore::ContentModule.create(
      title: "#4 Doing",
      tool_id: bit_core_tools(:activity_tracker),
      position: 5
    )
  end

  context "landing page and context page" do
    before do
      sign_in_participant participants(:participant1)
      visit ""
    end

    it "displays notifications until modules have been completed", :js do
      do_icon_count = page.find("li.DO.hidden-xs").all(".badge.badge-do").count

      expect(do_icon_count).to eq 1

      visit "/navigator/contexts/DO"
      with_scope ".container .left.list-group" do
        awareness_icon_count = page.all(".list-group-item-unread", text: "#1 Awareness").count

        expect(awareness_icon_count).to eq 1

        planning_icon_count = page.all(".list-group-item-unread", text: "#2 Planning").count

        expect(planning_icon_count).to eq 1

        planning_icon_count = page.all(".list-group-item-unread", text: "#3 Doing").count

        expect(planning_icon_count).to eq 1
      end
      page.find(".list-group-item-unread", text: "#1 Awareness").trigger("click")
      visit "/navigator/contexts/DO"
      page.find(".list-group-item-unread", text: "#2 Planning").trigger("click")
      visit "/navigator/contexts/DO"
      page.find(".list-group-item-unread", text: "#3 Doing").trigger("click")
      visit "/navigator/contexts/DO"
      click_on("Add a New Activity")
      visit "/navigator/contexts/DO"
      click_on("Your Activities")
      visit "/navigator/contexts/DO"
      with_scope "#sc-hamburger-menu" do
        click_on "Home"
      end
      do_icon_count = page.find("li.DO.hidden-xs > a").all(".badge.badge-do").count

      expect(do_icon_count).to eq 0

      visit "/navigator/contexts/DO"

      with_scope ".container .left.list-group" do
        awareness_icon_count = page.all(".list-group-item-unread", text: "#1 Awareness").count

        expect(awareness_icon_count).to eq 0

        planning_icon_count = page.all(".list-group-item-unread", text: "#2 Planning").count

        expect(planning_icon_count).to eq 0

        planning_icon_count = page.all(".list-group-item-unread", text: "#3 Doing").count

        expect(planning_icon_count).to eq 0
      end

    end

    it "keeps the order of task_status based on the order of the content_modules position even after updating a task status", :js do
      visit "/navigator/contexts/DO"
      expect(first(".container .list-group a").text).to eq "#1 Awareness"
      click_on("#1 Awareness")
      visit "/navigator/contexts/DO"
      expect(first(".container .list-group a").text).to eq "#1 Awareness"
    end

    it "not display unassigned content modules", :js do
      visit "/navigator/contexts/DO"
      expect(page.html).to include("#3 Doing")
      expect(page.html).not_to include("#4 Doing")
    end

    it "should display lesson slideshows even after they have been activated by a user", :js do
      visit "/navigator/contexts/LEARN"
      click_on "Do - Awareness Introduction"
      visit "/navigator/contexts/LEARN"
      expect(page).to have_link("Do - Awareness Introduction")
    end
  end

  context "Participant logs in on the first day of the trial with assigned tasks" do
    it "makes new tasks bold with a white background each day for reoccuring tasks", :js do
      Timecop.travel(Time.current - (1.day))
      sign_in_participant participants(:participant2)
      visit "/navigator/contexts/FEEL"
      new_task_count = page.all(".list-group-item-unread", text: "Tracking Your Mood").count
      expect(new_task_count).to eq 1

      click_on "Tracking Your Mood"

      expect(page).to have_selector("label.btn:nth-child(6)")

      page.find("label.btn:nth-child(6)").trigger("click")

      click_on "Continue"
      click_on "Continue"

      visit "/navigator/contexts/FEEL"
      new_task_count = page.all(".list-group-item-unread", text: "Tracking Your Mood").count

      expect(new_task_count).to eq 0
      Timecop.return
      sign_in_participant participants(:participant2)
      visit "/navigator/contexts/FEEL"
      new_task_count = page.all(".list-group-item-unread", text: "Tracking Your Mood & Emotions").count

      expect(new_task_count).to eq 1
    end
  end

  context "Participant logs in after assined tasks from previous days have been assigned" do
    before do
      sign_in_participant participants(:participant2)
    end

    it "displays tasks assigned on previous days" do
      visit "/navigator/contexts/DO"
      expect(task_status(:task_status5).release_day).to eq 1
      expect(participants(:participant2).membership.day_in_study).to eq 2
      with_scope ".left.list-group" do
        expect(page.all("a#task-status-#{task_status(:task_status5).id}").count).to eq 1
      end
    end

    it "doesn't display New! badge on the 'context' page if tasks are from previous days but unanswered" do
      visit "/navigator/contexts/DO"
      expect(task_status(:task_status5).release_day).to eq 1
      new_task_count = page.find("li.DO.hidden-xs li", text: "#{task_status(:task_status5).title}").all(".badge.badge-do").count
      expect(new_task_count).to eq 0
      expect(task_status(:task_status6).release_day).to eq 1
      new_task_count = page.find("li.DO.hidden-xs li", text: "#{task_status(:task_status6).title}").all(".badge.badge-do").count
      expect(new_task_count).to eq 0
    end

    it "displays only the most recent task if a content module has been assigned twice" do
      visit "/navigator/contexts/THINK"
      with_scope ".container .left.list-group" do
        expect(task_status(:task_status9).bit_core_content_module_id).to eq task_status(:task_status10).bit_core_content_module_id
        expect(task_status(:task_status9).release_day).to eq 1
        expect(page.all("a#task-status-#{task_status(:task_status9).id}").count).to eq 0
        expect(task_status(:task_status10).release_day).to eq 2
        expect(page.all("a#task-status-#{task_status(:task_status10).id}").count).to eq 1
      end
    end
  end
end
