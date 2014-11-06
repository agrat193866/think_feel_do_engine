require "spec_helper"

feature "managing tasks" do
  urls = ThinkFeelDoEngine::Engine.routes.url_helpers

  fixtures(
    :participants, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships,
    :tasks, :task_status
  )

  let(:admin1) { users(:admin1) }
  let(:participant3) { participants(:participant3) }
  let(:group1) { groups(:group1) }
  let(:group2) { groups(:group2) }
  let(:group3) { groups(:group3) }
  let(:task1) { tasks(:task1) }
  let(:task_status1) { task_status(:task_status1) }
  let(:task2) { tasks(:task2) }
  let(:task_status2) { task_status(:task_status2) }
  let(:do_awareness) { bit_core_content_modules(:do_awareness) }
  let(:do_planning) { bit_core_content_modules(:do_planning) }
  let(:do_doing) { bit_core_content_modules(:do_doing) }
  let(:feel) { bit_core_content_modules(:feeling_tracker_module3) }

  before do
    sign_in_user admin1
  end

  context "On new" do

    it "Assigning of modules with release days" do
      visit urls.manage_tasks_group_path(group2)

      task = Task.where(bit_core_content_module_id: do_doing.id, release_day: 1, group_id: group2.id).first

      expect(task).to be_nil

      select("#3 Doing", from: "Select Module")
      fill_in "Release Day", with: 1
      click_on "Assign"
      task = Task.where(bit_core_content_module_id: do_doing.id, release_day: 1, group_id: group2.id).first

      expect(task).to_not be_nil
      expect(page).to have_the_table(id: "tasks", cells: ["#3 Doing", "1", "false", "N/A"])
    end

    it "doesn't allow for the assigning a task with a release day after any participant has left a group" do
      visit urls.manage_tasks_group_path(group2)
      task = Task.where(bit_core_content_module_id: do_doing.id, release_day: 1, group_id: group2.id).first
      expect(task).to be_nil
      select("#3 Doing", from: "Select Module")
      fill_in "Release Day", with: 50
      click_on "Assign"
      task = Task.where(bit_core_content_module_id: do_doing.id, release_day: 1, group_id: group2.id).first
      expect(task).to be_nil
      expect(page).to have_content "Unable to assign task"
      expect(page).to have_content "Release day comes after some members are finished"
    end

    it "Assigns modules as reocurring every day until the end date" do
      visit urls.manage_tasks_group_path(group3)
      task = Task.where(bit_core_content_module_id: feel.id, release_day: 2, group_id: group3.id).first

      expect(task).to be_nil

      select("Tracking Your Mood & Emotions", from: "Select Module")
      fill_in "Release Day", with: 2
      check "Is this a recurring task?"
      fill_in "Recurring termination day", with: 4
      click_on "Assign"
      task = Task.where(bit_core_content_module_id: feel.id, release_day: 2, group_id: group3.id).first

      expect(task.is_recurring).to eq true

      sign_in_participant(participant3)

      expect(page.find(".FEEL.hidden-xs").all(".badge.badge-do").count).to eq 0 # 1st day - nothing has been assigned

      Timecop.travel(Time.current + (1.day)) # 2nd day
      sign_in_participant(participant3)

      expect(page.find(".FEEL.hidden-xs").all(".badge.badge-do").count).to eq 1

      click_on "FEEL Landing"

      expect(page.all(".list-group-item.list-group-item-unread", text: "Tracking Your Mood & Emotions").count).to eq 1

      Timecop.travel(Time.current + (1.days)) # 3rd day
      sign_in_participant(participant3)

      expect(page.find(".FEEL.hidden-xs").all(".badge.badge-do").count).to eq 1

      click_on "FEEL Landing"

      expect(page.all(".list-group-item.list-group-item-unread", text: "Tracking Your Mood & Emotions").count).to eq 1

      Timecop.travel(Time.current + (1.days)) # 4th day
      sign_in_participant(participant3)

      expect(page.find(".FEEL.hidden-xs").all(".badge.badge-do").count).to eq 1

      click_on "FEEL Landing"

      expect(page.all(".list-group-item.list-group-item-unread", text: "Tracking Your Mood & Emotions").count).to eq 1

      Timecop.travel(Time.current + (1.days)) # 5th day
      sign_in_participant(participant3)

      expect(page.find(".FEEL.hidden-xs").all(".badge.badge-do").count).to eq 0

      click_on "FEEL Landing"

      expect(page).not_to have_content("Tracking Your Mood")

      sign_in_user admin1
      visit urls.manage_tasks_group_path(group3)

      expect(page).to have_the_table(
        id: "tasks",
        cells: [
          "Tracking Your Mood & Emotions",
          "2",
          "true",
          "4",
          "Unassign"
        ]
      )
    end
  end

  it "Unassigns a task" do
    visit urls.manage_tasks_group_path(group1)
    task = Task.where(bit_core_content_module_id: do_awareness.id, release_day: 1, group_id: group1.id).first
    expect(task).to_not be_nil
    with_scope "#task-#{task.id}" do
      click_on "Unassign"
    end
    task = Task.where(bit_core_content_module_id: do_awareness.id, release_day: 1, group_id: group1.id).first
    expect(task).to be_nil
  end
end
