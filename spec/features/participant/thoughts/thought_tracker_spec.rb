require "rails_helper"

feature "thought tracker", type: :feature do
  fixtures(
    :arms, :participants, :users, :groups, :memberships, :"bit_core/slideshows",
    :"bit_core/slides", :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :content_provider_policies, :tasks, :thought_patterns, :thoughts,
    :task_status
  )

  before do
    sign_in_participant participants(:participant1)
    visit "/navigator/contexts/THINK"
  end

  it "shows an introductory slideshow to the participant" do
    within ".left.list-group" do
      click_on bit_core_content_modules(:think_identifying).title
    end

    expect(page).to have_text(bit_core_slides(:think_identifying_intro1).title)

    click_on "Next"

    expect(page).to have_text(bit_core_slides(:think_identifying_intro2).title)

    click_on "Next"

    expect(page).to have_text(bit_core_slides(:think_identifying_intro3).title)

    click_on "Next"

    expect(page).to have_text(bit_core_slides(:think_identifying_intro4).title)

    click_on "Next"
  end

  it "skips content that is skippable" do
    within ".container .left.list-group" do
      click_on bit_core_content_modules(:think_identifying).title
    end

    click_on "Skip"
    expect(page).to have_text("Now, your turn...")
  end

  it "implements a 'Back' button for slideshows " do
    within ".container .left.list-group" do
      click_on bit_core_content_modules(:think_identifying).title
    end

    expect(page).to have_text(bit_core_slides(:think_identifying_intro1).title)
    expect(page).to_not have_text "Back"

    click_on "Next"

    expect(page).to have_text(bit_core_slides(:think_identifying_intro2).title)
    expect(page).to have_text "Next"

    click_on "Back"

    expect(page).to have_text(bit_core_slides(:think_identifying_intro1).title)
    expect(page).to have_text "Next"
    expect(page).to_not have_text "Back"
  end

  it "shows participant intro to reshape module", :js do
    page.find(".list-group-item", text: "#3 Reshape").trigger("click")
    expect(page).to have_text "Challenging Harmful Thoughts"
    click_on "Next"
  end

  it "should not display a way to updated harmful thought's effect" do
    visit "/navigator/modules/#{bit_core_content_modules(:think_module_thoughts_table).id}"
    click_on "Edit Thoughts"

    expect(page).to_not have_content "Effect"
    expect(page).to_not have_content "harmful"
    expect(page).to_not have_content "helpful"
    expect(page).to_not have_content "neither"
  end

  it "shows a vizualization of thought distortions and their associated harmful thoughts", :js do
    page.find(".list-group-item-unread", text: "Add a New Thought").click
    fill_in "thought_content", with: "something something"
    select "Overgeneralization", from: "What thought pattern is this an example of?"
    fill_in "Challenging Thought", with: "Oh my"
    fill_in "As If Action", with: "Not sure"

    click_on "Next"
    click_on "Next"

    expect(page).to have_text("Think Landing")

    page.find(".list-group-item-read", text: "Add a New Thought").click

    fill_in "thought_content", with: "something something 2"
    select "Overgeneralization", from: "What thought pattern is this an example of?"
    fill_in "Challenging Thought", with: "Oh my"
    fill_in "As If Action", with: "Not sure"

    click_on "Next"
    # don't care about the foot overlapping
    find("a", text: "Next").trigger("click")

    expect(page).to have_text("Think Landing")

    page.find(".list-group-item-read", text: "Add a New Thought").click

    fill_in "thought_content", with: "something something 3"
    select "Overgeneralization", from: "What thought pattern is this an example of?"
    fill_in "Challenging Thought", with: "Oh my"
    fill_in "As If Action", with: "Not sure"

    click_on "Next"
    find("a", text: "Next").trigger("click")

    expect(page).to have_text("Think Landing")

    expect(page).to have_text "Overgeneralization"
    find(".thoughtviz_text").click

    expect(page).to have_text "Thought Distortions"
  end
end