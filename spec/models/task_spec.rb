require "rails_helper"

describe Task do
  fixtures(
    :users, :user_roles, :participants, :"bit_core/slideshows",
    :"bit_core/slides", :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships, :tasks
  )

  let(:task1) { tasks(:task1) }
  let(:task_learning7) { tasks(:task_learning7) }

  it "requires release day" do
    task = Task.new(release_day: nil).tap(&:valid?)

    expect(task.errors.get(:release_day).count).to eq 1
  end

  it "does not allow a group and module to be assigned on the same release day" do
    task2 = Task.new(
      group_id: task1.group_id,
      bit_core_content_module_id: task1.bit_core_content_module_id,
      release_day: task1.release_day
    ).tap(&:valid?)

    expect(task2.errors.get(:release_day).count).to eq 1
  end

  it "disallows release days after the last day of any membership" do
    task2 = Task.new(
      group_id: task1.group_id,
      release_day: task1.release_day + 100
    ).tap(&:save)

    expect(task2.errors.get(:base).count).to eq 1
  end

  describe "Group with discontinued, withdraw, and active memberships" do
    let(:new_task) do
      Task.new(
        group: groups(:group6),
        release_day: 3,
        bit_core_content_module: bit_core_content_modules(:do_awareness))
    end

    def build_membership(attributes = {})
      Membership.create({
        participant: participants(:inactive_participant),
        group: groups(:group6),
        start_date: Date.today.advance(days: -2),
        end_date: Date.today.advance(days: -1)
      }.merge(attributes))
    end

    it "allows creation of task statuses when an active membership exist" do
      build_membership(
        start_date: Date.today,
        end_date: Date.today.advance(days: 3))
      new_task.save

      expect(new_task.errors.count).to eq 0
    end

    it "allows creation of task statuses when a discontinued membership exist" do
      build_membership(is_complete: true)
      new_task.save

      expect(new_task.errors.count).to eq 0
    end

    it "allows creation of task statuses when a withdrawn membership exist" do
      build_membership
      new_task.save

      expect(new_task.errors.count).to eq 0
    end
  end

  it "persists if its creator is destroyed" do
    creator = task1.creator
    creator.destroy
    task = Task.find(task1.id)
    expect(task.creator_id).to eq(nil)
  end

  describe "TaskStatus creation" do
    let(:member_count) { task1.group.memberships.count }
    let(:release_day) { task1.release_day + 2 }

    context "when non-recurring" do
      it "adds task statuses for each membership" do
        expect do
          Task.create!(
            group_id: task1.group_id,
            bit_core_content_module_id: task1.bit_core_content_module_id,
            release_day: release_day
          )
        end.to change { TaskStatus.count }.by(member_count)
      end
    end

    context "when being listed" do
      it "displays non-html formatted title for non-lesson content modules" do
        expect(task1.title).to eq("#1 Awareness")
      end

      it "displays html formatted title for lesson modules" do
        expect(task_learning7.title).to match(/<.*>Feel - Emotions Introduction<\/.*>/)
      end
    end

    context "when recurring" do
      it "adds task statuses for each membership an each day" do
        total_days_in_study = task1
                              .group.memberships.all.to_a
                              .sum { |m| m.length_of_study - release_day + 1 }

        expect do
          Task.create!(
            group_id: task1.group_id,
            bit_core_content_module_id: task1.bit_core_content_module_id,
            release_day: release_day,
            is_recurring: true
          )
        end.to change { TaskStatus.count }.by(total_days_in_study)
      end
    end
  end

  describe "scopes" do
    let(:group) { groups(:group4) }
    let(:module1) { bit_core_content_modules(:do_awareness) }
    let(:learning_module) { bit_core_content_modules(:slideshow_content_module_1) }

    it ".learning returns tasks associated with learning content modules" do
      count = Task.learning.count
      Task.create(
        group: group,
        bit_core_content_module: module1,
        release_day: 3)
      Task.create(
        group: group,
        bit_core_content_module: learning_module,
        release_day: 3)

      expect(Task.learning.count).to eq count + 1
    end
  end

  describe "participant related utility methods" do
    fixtures(:all)

    it "incomplete_participant_list should return a list of participants "\
    "that have not completed this task " do
      expect(task1.incomplete_participant_list.count).to be >= 2
    end

    it "complete_participant_list should return a list of participants "\
    "that have completed this task " do
      expect(task1.complete_participant_list.count).to be >= 2
    end

    it "total_assigned should return the total number of statuses" do
      expect(task1.total_assigned).to be >= (2)
    end

    it "total_read should return the total statuses marked as complete" do
      expect(task1.total_read).to be >= (0)
    end
  end
end
