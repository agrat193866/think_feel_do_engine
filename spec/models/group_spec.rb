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
end