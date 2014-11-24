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
    visit "/arms/#{arms(:arm1).id}/bit_maker/content_modules"
  end

  it "have a corresponding show page that displays the title" do
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
end