require "rails_helper"

describe Group do
  fixtures :all

  let(:group) { groups(:group_for_arm4) }
  let(:lesson_module) { bit_core_content_modules(:slideshow_content_module_1) }
  let(:non_lesson_module) { bit_core_content_modules(:feeling_tracker_emotions_list) }

  it ".learning_tasks returns the tasks whose content modules are lesson modules" do
    count = group.learning_tasks.count
    Task.create(
      group: group,
      bit_core_content_module: lesson_module,
      is_recurring: false,
      release_day: 1
    )
    Task.create(
      group: group,
      bit_core_content_module: non_lesson_module,
      is_recurring: false,
      release_day: 1
    )
    group.reload

    expect(group.learning_tasks.count).to eq(count + 1)
  end

  it ".logins_by_week returns a count of logins "\
  " for the first week" do
    expect(group.logins_by_week(1)).to eq(0)
  end

  it ".thoughts_by_week returns a count of thoughts "\
  " for the first week" do
    expect(group.thoughts_by_week(1)).to eq(0)
  end

  it ".activities_past_by_week returns a count of activities "\
  " planned for the first week" do
    expect(group.activities_past_by_week(1)).to eq(0)
  end

  it ".activities_future_by_week returns a count of activities "\
  " monitored for the first week" do
    expect(group.activities_future_by_week(1)).to eq(0)
  end
end