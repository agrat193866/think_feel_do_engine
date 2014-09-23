require "spec_helper"

describe TaskStatus do
  fixtures(
    :users, :user_roles, :participants, :"bit_core/slideshows",
    :"bit_core/slides", :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships, :tasks
  )

  let(:task1) { tasks(:task1) }

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

  describe "TaskStatus creation" do
    let(:member_count) { task1.group.memberships.count }
    let(:release_day) { task1.release_day + 1 }

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

    context "when recurring" do
      it "adds task statuses for each membership an each day" do
        total_days_in_study = task1.group.memberships.all.to_a
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
end
