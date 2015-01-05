require "spec_helper"

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
    task = Task.where(bit_core_content_module_id: think_identifying.id, release_day: 3, group_id: group1.id).first
    expect(task).to be_nil
    release_day = 3
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
end
