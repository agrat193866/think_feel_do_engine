require "spec_helper"

feature "Content Modules", type: :feature do
  fixtures(
    :arms, :participants, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships,
    :tasks, :task_status
  )

  let(:group1) { groups(:group1) }
  let(:do_awareness) { bit_core_content_modules(:do_awareness) }

  before do
    sign_in_user users :admin1
  end

  it "have a corresponding show page that displays the title" do
    visit "/arms/#{arms(:arm1).id}/bit_maker/content_modules"

    expect(page).to have_content "#1 Awareness"

    original_task = Task.where(group_id: group1.id, bit_core_content_module_id: do_awareness.id, release_day: 1).first

    expect(original_task).to_not be_nil

    task_status = TaskStatus.where(task_id: original_task.id).first

    expect(task_status).to_not be_nil

    click_on "#1 Awareness"
    click_on "Destroy"
    deleted_task = Task.where(group_id: group1.id, bit_core_content_module_id: do_awareness.id, release_day: 1).first

    expect(deleted_task).to be_nil

    task_status = TaskStatus.where(task_id: original_task.id).first

    expect(task_status).to be_nil
    expect(page).to have_content "Content module along with any associated tasks were successfully destroyed."

    visit "/arms/#{arms(:arm1).id}/bit_maker/content_modules"

    expect(page).to_not have_content "#1 Awareness"
  end

  it "should scope modules by arm" do
    visit "/arms/#{arms(:arm2).id}/bit_maker/content_modules"

    expect(page).to_not have_content "#1 Awareness"
  end

  it "should scope modules by arm when on new" do
    visit "/arms/#{arms(:arm1).id}/bit_maker/content_modules/new"

    expect(page).to have_content "LEARN"
    expect(page).to_not have_content "BRAIN"

    visit "/arms/#{arms(:arm2).id}/bit_maker/content_modules/new"

    expect(page).to_not have_content "LEARN"
    expect(page).to have_content "BRAIN"
  end

  it "should scope modules by arm when on edit" do
    visit "/arms/#{arms(:arm1).id}/bit_maker/content_modules/#{bit_core_content_modules(:home_landing).id}/edit"

    expect(page).to have_content "LEARN"
    expect(page).to_not have_content "BRAIN"

    visit "/arms/#{arms(:arm2).id}/bit_maker/content_modules/#{bit_core_content_modules(:home_landing_for_different_arm).id}/edit"

    expect(page).to_not have_content "LEARN"
    expect(page).to have_content "BRAIN"
  end
end