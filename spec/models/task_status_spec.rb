require "rails_helper"

describe TaskStatus do
  fixtures :all

  let(:user) { users(:clinician1) }
  let(:group1) { groups(:group1) }
  let(:group2) { groups(:group2) }
  let(:participant) { participants(:active_participant) }
  let(:membership) { memberships(:active_membership) }
  let(:think_identifying) { bit_core_content_modules(:think_identifying) }
  let(:slideshow_content_module_13) { bit_core_content_modules(:slideshow_content_module_13) }

  it "should be created and assigned to members when a task is assigned to a group" do
    tasks = membership.tasks.count
    task = Task.where(group: group2, bit_core_content_module: think_identifying, release_day: 1).first
    expect(task).to be_nil
    task = user.tasks.build(group: group2, bit_core_content_module: think_identifying, release_day: 1)
    task.save!
    task = Task.where(group: group2, bit_core_content_module: think_identifying, release_day: 1).first
    expect(task).not_to be_nil
    membership.reload
    expect(membership.tasks.count).to eq tasks + 1
    status = TaskStatus.where(membership_id: membership.id, task: task).first
    expect(status).not_to be_nil
  end

  it "creates one task statuses for each membership when assigned" do
    task = user.tasks.build(
      group_id: group1.id,
      bit_core_content_module_id: slideshow_content_module_13.id,
      release_day: 2)
    task.save!
    group1.memberships.each do |membership|
      expect(TaskStatus.where(task_id: task.id, membership_id: membership.id).count).to eq 1
    end
  end

  it "creates task_statuses for all days following the release day for each participant when task is assigned as recurring" do
    task = Task.where(bit_core_content_module_id: think_identifying.id, release_day: 4, group_id: group1.id).first
    expect(task).to be_nil
    release_day = 4
    task = user.tasks.build(
      group_id: group1.id,
      bit_core_content_module_id: think_identifying.id,
      release_day: release_day,
      is_recurring: true)
    task.save!
    group1.memberships.each do |membership|
      task_status_count = membership.length_of_study - release_day + 1
      expect(TaskStatus.where(task_id: task.id, membership_id: membership.id).count).to eq task_status_count
    end
  end

  describe "scopes" do
    let(:lesson_module) { bit_core_content_modules(:slideshow_content_module_1) }
    let(:membership) { memberships(:membership1) }
    let(:task) { tasks(:task5_day2) }
    let(:task1) { tasks(:task5_day3) }
    let(:task_termination_day1) { tasks(:task10) }
    let(:task_termination_day2) { tasks(:task10_2) }
    let(:task_termination_day3) { tasks(:task10_3) }

    it ".available_for_learning returns task statuses having a start day less than or equal to today" do
      Timecop.travel(Date.today.advance(days: 1)) do
        count = TaskStatus.available_for_learning(membership).count
        TaskStatus.create(
          start_day: 1,
          membership: membership,
          task: task)
        TaskStatus.create(
          start_day: 2,
          membership: membership,
          task: task)
        TaskStatus.create(
          start_day: 3,
          membership: membership,
          task: task)

        expect(TaskStatus.available_for_learning(membership).count).to eq count + 2
      end
    end

    it ".available_by_day returns tasks status that have a previous start day earlier than or equal to current today" do
      count = TaskStatus.available_by_day(2).count
      TaskStatus.create(
        task: task,
        membership: membership,
        start_day: 1)
      TaskStatus.create(
        task: task,
        membership: membership,
        start_day: 2)
      TaskStatus.create(
        task: task,
        membership: membership,
        start_day: 3)

      expect(TaskStatus.available_by_day(2).count).to eq count + 2
    end

    it ".incomplete returns task statuses that are not yet marked completed" do
      count = TaskStatus.incomplete.count
      TaskStatus.create(
        start_day: 1,
        membership: membership,
        task: task,
        completed_at: nil)
      TaskStatus.create(
        start_day: 1,
        membership: membership,
        task: task1,
        completed_at: Time.now)

      expect(TaskStatus.incomplete.count).to eq count + 1
    end

    it ".incomplete_by_day returns task statuses that are have a start day of less than today AND not yet completed" do
      count = TaskStatus.incomplete_by_day(2).count
      TaskStatus.create(
        start_day: 1,
        membership: membership,
        task: task,
        completed_at: nil)
      TaskStatus.create(
        start_day: 1,
        membership: membership,
        task: task1,
        completed_at: Time.now)
      TaskStatus.create(
        start_day: 3,
        membership: membership,
        task: task1,
        completed_at: nil)

      expect(TaskStatus.incomplete_by_day(2).count).to eq count + 1
    end

    it ".incomplete_by_day returns task statuses that are have a start day equal to today AND not yet completed" do
      count = TaskStatus.incomplete_by_day(1).count
      TaskStatus.create(
        start_day: 1,
        membership: membership,
        task: task,
        completed_at: nil)
      TaskStatus.create(
        start_day: 1,
        membership: membership,
        task: task1,
        completed_at: Time.now)

      expect(TaskStatus.incomplete_by_day(1).count).to eq count + 1
    end

    it ".incomplete_on_day returns task statuses that are have a start day equal to today AND not yet completed" do
      count = TaskStatus.incomplete_on_day(2).count
      TaskStatus.create(
        start_day: 1,
        membership: membership,
        task: task,
        completed_at: nil)
      TaskStatus.create(
        start_day: 1,
        membership: membership,
        task: task1,
        completed_at: Time.now)
      TaskStatus.create(
        start_day: 2,
        membership: membership,
        task: task1,
        completed_at: nil)

      expect(TaskStatus.incomplete_on_day(2).count).to eq count + 1
    end

    it ".not_terminated_by_day returns task statuses where the task termination day is nil" do
      count = TaskStatus.not_terminated_by_day(3).count
      TaskStatus.create(
        membership: membership,
        task: task_termination_day1
      )
      TaskStatus.create(
        membership: membership,
        task: task
      )
      expect(TaskStatus.not_terminated_by_day(3).count).to eq count + 1
    end

    it ".not_terminated_by_day returns tasks statuses where the termination day is today or in the future" do
      count = TaskStatus.not_terminated_by_day(2).count

      TaskStatus.create(
        membership: membership,
        task: task_termination_day1
      )
      TaskStatus.create(
        membership: membership,
        task: task_termination_day2
      )
      TaskStatus.create(
        membership: membership,
        task: task_termination_day3
      )
      expect(TaskStatus.not_terminated_by_day(2).count).to eq count + 2
    end
  end
end
