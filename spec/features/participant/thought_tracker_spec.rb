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

  it "implements #1 Identifying" do
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

    expect(page).to have_text("Now, your turn...")

    fill_in("thought_content", with: "my great thought")
    click_on("Next")

    expect(page).to have_text("Now list another harmful thought...")

    fill_in("thought_content", with: "another thought")
    click_on("Next")

    expect(page).to have_text("Just one more harmful thought")

    fill_in("thought_content", with: "another thought")
    click_on("Next")

    expect(page).to have_text("Good work")

    click_on("Next")

    expect(page).to have_text("#1 Identifying")
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

  it "implements #2 Patterns", :js do
    within ".left.list-group" do
      click_on "#2 Patterns"
    end

    expect(page).to have_text "Like we said, you are what you think..."

    i = 0
    while i < 9
      click_on "Next"
      i += 1
    end

    expect(page).to have_text "Helpful Thoughts"

    click_on "Next"

    expect(page).to have_text "Let's start by figuring out which thought patterns the harmful thoughts you identified might match."
    expect(page).to have_text "One thought you had"
    expect(page.find(".panel-body.adjusted-list-group-item").text).to satisfy { |s| ["ARG!", "I am insignificant"].include?(s) }

    select("Overgeneralization", from: "What thought pattern is this an example of?")
    # expect(page).to have_text "You see a single negative event as a never-ending pattern of defeat."

    click_on "Next"
    expect(page).to have_text "Thought saved"
    expect(page.find(".panel-body.adjusted-list-group-item").text).to satisfy { |s| ["ARG!", "I am insignificant"].include?(s) }

    select("Mental Filter", from: "What thought pattern is this an example of?")
    # expect(page).to have_text "You pick out a single negative defeat and dwell on it exclusively so that your vision of reality becomes darkened, like the drop of ink that colors the entire beaker of water."

    click_on "Next"

    expect(page).to have_text "Good work!"

    click_on "Next"
    click_on "Thoughts"

    expect(page).to have_text("I am insignificant")
  end

  it "implements #3 Reshape", :js do
    page.find(".list-group-item", text: "#3 Reshape").trigger("click")
    expect(page).to have_text "Challenging Harmful Thoughts"

    click_on "Next"

    expect(page).to have_text "You said you had the following unhelpful thoughts:"
    expect(page).to have_text "In case you've forgotten"
    expect(page).to have_text "I am useless"
    expect(page).to have_text "We're going to ask you to challenge each thought"

    page.find("a.btn", text: "Next").trigger("click")

    expect(page).to have_text "Challenging a thought means evaluating if the thought is accurate. A useful way to do this is to check the facts to see if the thought is true."

    page.find("a.btn", text: "Next").trigger("click")

    expect(page).to have_text "You said that you thought"

    expect(page).to have_text "I am useless"
    expect(page).to have_text "...and that this relates to this harmful thought pattern: Labeling and Mislabeling"
    expect(page).to have_text "This is an extreme form of overgeneralization. Instead of describing your error, you attach a negative label to yourself: \"I'm a loser.\" When someone else's behavior rubs you the wrong way, you attach a negative label to him: \"He's a goddam louse\". Mislabeling involves describing an event with language that is highly colored and emotionally loaded."

    click_on "Next"

    expect(page).to have_text "1 of 3"

    fill_in "Now you try it. Write a challenging thought below", with: "Challenge this!"

    click_on "Next"

    expect(page).to have_text "Because what you THINK, FEEL, Do are related, a challenging thought can change how you act."

    click_on "Next"

    expect(page).to have_text "You thought"
    expect(page).to have_text "I am useless"
    expect(page).to have_text "A challenging thought was..."
    expect(page).to have_text "Challenge this!"
    page.execute_script("$('#thought_act_as_if').val('I would act on being superman!')")

    # fill_in "What could you do to ACT AS IF you believe this?", with: "I would act on being superman!"
    click_on "Next"
    expect(page).to have_text "Thought saved"

    visit "/navigator/contexts/THINK"
    page.find("a", text: "Thoughts").trigger("click")

    expect(page).to have_text("I am useless")
    expect(page).to have_text("Challenge this!")
    expect(page).to have_text("I would act on being superman!")
  end

  it "implements 'Add a New Thought'" do
    within ".THINK ul" do
      click_on "Add a New Thought"
    end

    expect(page).to have_text "Add a New Thought"

    fill_in("thought_content", with: "I like tomatoes")
    select "Overgeneralization", from: "What thought pattern is this an example of?"
    fill_in("Challenging Thought", with: "Oh my")
    fill_in("As If Action", with: "Not sure")
    click_on("Next")

    expect(page).to have_text("Thought saved")
    expect(page).to have_text "Harmful Thoughts"

    expect(page).to have_content("I like tomatoes")
    expect(page).to have_selector(:link_or_button, "Add a New Thought", count: 1)
    expect(page).to have_selector(:link_or_button, "Next")
  end

  it "implements a new thought from the page where all harmful thoughts are displayed" do
    within ".THINK ul" do
      click_on "Thoughts"
    end
    expect(page).to have_text "Harmful Thoughts"
    expect(page).to_not have_the_table(id: "thoughts", cells: ["I like tomatoes", "Overgeneralization", "harmful", "Oh my", "Not sure"])

    within "#tool-layout.container" do
      click_on "Add a New Thought"
    end

    fill_in("thought_content", with: "I like tomatoes")
    select "Overgeneralization", from: "What thought pattern is this an example of?"
    fill_in("Challenging Thought", with: "Oh my")
    fill_in("As If Action", with: "Not sure")
    click_on("Next")

    expect(page).to have_text("Thought saved")
    expect(page).to have_text "Harmful Thoughts"
    expect(page).to have_text("I like tomatoes")
    expect(page).to have_selector(:link_or_button, "Add a New Thought", count: 1)
    expect(page).to have_selector(:link_or_button, "Next")
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
