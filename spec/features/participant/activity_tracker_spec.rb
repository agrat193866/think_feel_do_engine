require "rails_helper"

feature "activity tracker", type: :feature do
  fixtures(
    :participants, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :users, :arms,
    :"bit_core/content_modules", :"bit_core/content_providers",
    :activity_types, :activities, :groups, :memberships, :tasks, :task_status, :awake_periods
  )

  context "Participant1 is logged in" do
    let(:participant1) { participants(:participant1) }

    before do
      sign_in_participant participant1
      visit "/navigator/contexts/DO"
    end

    def choose_rating(element_id, value)
      find("##{ element_id } select").find(:xpath, "option[#{(value + 1)}]").select_option
    end

    it "implements #1 Awareness", :js do
      # Implements Awareness with last recorded awake period incomplete
      within ".container .left.list-group" do
        click_on "#1 Awareness"
      end
      expect(page).to have_content "This is just the beginning..."

      click_on "Next"
      expect(page).to have_content "OK, let's talk about yesterday."
      expect(page).to have_content "Last Recorded Awake Period:"

      click_on "Complete"
      expect(page).to have_content "Review Your Day"

      fill_in "activity_type_0", with: "Get ready for work"
      choose_rating("pleasure_0", 6)
      choose_rating("accomplishment_0", 7)
      fill_in "activity_type_1", with: "Travel to work"
      choose_rating("pleasure_1", 2)
      choose_rating("accomplishment_1", 3)
      fill_in "activity_type_2", with: "Work"
      choose_rating("pleasure_2", 8)
      choose_rating("accomplishment_2", 9)
      click_on "Next"

      expect(page).to have_content "Take a look - does this all seem right? Recently, you..."

      click_on "Next"
      expect(page).to have_content "Things you found fun."

      click_on "Next"
      expect(page).to have_content "Things that make you feel like you've accomplished something."

      click_on "Next"
      expect(page).to have_content "Your Activities"
      # Implements Awareness with new awake period
      click_on "#1 Awareness"
      expect(page).to have_content "This is just the beginning..."

      click_on "Next"
      expect(page).to have_content "OK, let's talk about yesterday."

      today = Date.today
      select today.strftime("%a") + " 1 AM", from: "awake_period_start_time"
      select today.strftime("%a") + " 5 AM", from: "awake_period_end_time"
      click_on "Create"

      expect(page).to have_text("Review Your Day")

      fill_in "activity_type_0", with: "ate cheeseburgers"
      choose_rating("pleasure_0", 9)
      choose_rating("accomplishment_0", 4)

      fill_in "activity_type_1", with: "ate bad cheeseburgers"
      choose_rating("pleasure_1", 0)
      choose_rating("accomplishment_1", 0)

      find("#copy_2").trigger("click")

      fill_in "activity_type_3", with: "ate bad cheeseburgers"
      choose_rating("pleasure_3", 0)
      choose_rating("accomplishment_3", 1)

      click_on "Next"
      expect(page).to have_text("ate cheeseburgers")
      expect(page).to have_text("ate bad cheeseburgers", count: 3)

      click_on "Next"

      expect(page).to have_text("Things you found fun.")
      expect(page).to have_text("ate cheeseburgers")

      click_on "Next"

      expect(page).to have_text("Things that make you feel like you've accomplished something.")
      expect(page).not_to have_text("ate cheeseburgers")

      click_on "Next"
      expect(page).to have_text("#1 Awareness")
    end

    it "implements #2 Planning", :js do
      page.find(".list-group-item", text: "#2 Planning").trigger("click")

      expect(page).to have_text "The last few times you were here..."

      click_on "Next"

      expect(page).to have_text("We want you to plan one fun thing")

      find("input[value='Loving'][type='radio']").click
      tomorrow = Date.today + 1
      find(".fa.fa-calendar").click
      click_on tomorrow.strftime("%e")
      choose_rating "pleasure_0", 10
      choose_rating "accomplishment_0", 10
      click_on "Next"
      choose_rating "pleasure_0", 10
      choose_rating "accomplishment_0", 10

      expect(page).to have_text("Now, plan something that gives you a sense of accomplishment.")

      fill_in "activity_activity_type_new_title", with: "Parkour"
      tomorrow = Time.now + 1.days
      find(".fa.fa-calendar").click
      click_on tomorrow.strftime("%e")
      click_on "Next"

      expect(page.body).to have_text("OK... the most important thing")

      click_on "Next"

      expect(page).to have_text("Your Planned Activities")

      click_on "Next"

      expect(page).to have_text("#3 Doing")
      expect(page).to have_text("Upcoming Activities")
      expect(page).to have_text("Recent Past Activities")
      expect(page).to have_text("Really fun (10)")
      expect(page).to have_text("High Importance (10)")
    end

    it "implements #3 Doing" do
      within ".container .left.list-group" do
        click_on bit_core_content_modules(:do_doing).title
      end

      expect(page).to have_text(bit_core_slides(:do_doing_intro1).title)

      click_on "Next"

      expect(page).to have_text(bit_core_slides(:do_doing_intro2).title)

      click_on "Next"

      expect(page).to have_text("You said you were going to")
      expect(page).to have_text("Loving")
    end

    it "edits activities", :js do
      expect(page).to have_text "Recent Past Activities"
      expect(page).to have_text "Loving"

      click_on "Edit"

      expect(page).to have_text "Loving"

      find(".radio_yes").trigger("click")

      expect(page).to have_text "How much pleasure did you get from doing this?"

      execute_script("$('.pleasure-container input:first').trigger('click')")
      execute_script("$('.accomplishment-container input:first').trigger('click')")
      click_on "Next"

      expect(page).to have_text "Activity saved"
      expect(page).to have_text "Good Work!"

      click_on "Next"

      expect(page).to have_text "#1 Awareness"
      expect(page).to_not have_text "Recent Past Activities"
      expect(page).to_not have_text "Loving"
      expect(page).to_not have_text "Parkour"
      expect(page).to_not have_link "Edit"
    end
  end

  context "Traveling Participant is logged in" do
    let(:participant) { participants(:traveling_participant1) }
    let(:activity) { activities(:p2_activity_next_day) }

    before do
      t = Time.now - 268.hours
      Timecop.travel(t)
      sign_in_participant participant
      visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}"
    end

    after do
      t = Time.now + 268.hours
      Timecop.travel(t)
    end

    it "can't edit an activity's actual accomplishment or pleasurable intensity if it is in the future" do
      expect(page).to have_text "Commuting"
      within "#collapse-activity-#{activity.id}" do
        expect(page).to_not have_text "Edit"
      end
    end
  end

  context "Participant with activities is logged in" do
    let(:participant) { participants(:traveling_participant1) }
    let(:activity) { activities(:p2_activity_1_hr_ago) }

    before do
      t = Time.now - 288.hours
      Timecop.travel(t)
      sign_in_participant participant
      visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}"
    end

    after do
      t = Time.now + 288.hours
      Timecop.travel(t)
    end

    it "displays daily activity averages" do
      today = Time.now
      expect(page).to have_text "Daily Averages for " + today.strftime("%b %d, %Y")
      expect(page).to have_text "Mood: No Recordings"
      expect(page).to have_text "Positive Emotions: No Recordings"
      expect(page).to have_text "Negative Emotions: No Recordings"
    end

    it "displays daily summary information" do
      expect(page).to have_text "Daily Summaries"
      expect(page).to have_text "You spent 1 hour engaged in pleasurable activities and 1 hour engaged in accomplished activities."
      expect(page).to have_text "1 activity you recorded as high pleasure, while 1 activity you recorded as high accomplishment, and 1 activity you recorded is both high pleasure and high accomplishment."
      expect(page).to have_text "Completion Score: 67% (You completed 2 out of 3 activities that you scheduled.)"
      expect(page).to have_text "Average Accomplishment Discrepancy: 1.0"
      expect(page).to have_text "Average Pleasure Discrepancy: 1.0"
    end

    it "navigates to today when 'Today' button is clicked" do
      today = Time.now
      yesterday = today - 1.days
      visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}"
      click_on "Previous Day"
      expect(page).to have_text "Daily Averages for " + yesterday.strftime("%b %d, %Y")
      expect(page).to_not have_text "Daily Averages for" + today.strftime("%b %d, %Y")

      click_on "Today"

      expect(page).to have_text "Daily Averages for " + today.strftime("%b %d, %Y")
    end

    it "displays a list of activities and activity details" do
      expect(page).to have_text "Eating breakfast"
      expect(page).to have_text "Accomplishment: 9 · Pleasure: 9"
      expect(page).to have_text "Accomplishment  Pleasure"
      expect(page).to have_text "Predicted High Importance: 10 Really fun: 10"
      expect(page).to have_text "Actual  High Importance: 9  Really fun: 9"
      expect(page).to have_text "Difference  1  1"
      expect(page).to have_text "Working"
      expect(page).to have_text "Accomplishment: 2 · Pleasure: 2"
    end

    it "title is displayed when data is selected", :js do
      click_on "Day"
      click_on "Visualize"
      click_on "Last 3 Days"

      expect(page).to have_text "3-Day View"

      click_on "Day"
      click_on "Visualize"
      click_on "Last 7 Days"

      expect(page).to have_text "7-Day View"
    end

    it "allows for the updating of a past activity", :js do
      page.all("a", text: "Working")[1].click

      expect(page).to have_text "Predicted Average Importance: 6 Kind of fun: 5"
      expect(page).to have_text "Actual  Not answered: Not answered:"
      expect(page).to have_text "Difference N/A N/A"

      within "form#edit_activity_#{activity.id}" do
        click_on "Edit"
        select "1", from: "Actual accomplishment intensity"
        select "8", from: "Actual pleasure intensity"
        click_on "Update"
      end

      expect(page).to have_text "Accomplishment: 1 · Pleasure: 8"

      page.all("a", text: "Working")[1].click

      expect(page).to have_text "Predicted  Average Importance: 6 Kind of fun: 5"
      expect(page).to have_text "Actual  Low Importance: 1 Really fun: 8"
      expect(page).to have_text "Difference  5  3"
    end

    it "allows for the paginating to the previous day's activities" do
      expect(page).to_not have_text "Jogging"

      click_on "Previous Day"

      expect(page).to have_text "Jogging"
      expect(page).to have_text "Accomplishment: 6 · Pleasure: 7"
    end

    it "allows for the paginating to the next day's activities" do
      expect(page).to_not have_text "Commuting"
      expect(page).to_not have_text "Predicted High Importance: 8 Kind of fun: 4"

      click_on "Next Day"

      expect(page).to have_text "Commuting"
      expect(page).to have_text "Predicted High Importance: 8 Kind of fun: 4"
      expect(page).to have_text "Actual  Not answered: Not answered:"
      expect(page).to have_text "Difference  N/A N/A"
    end
  end

  context "Participant with no predictions for acitivites is logged in" do
    let(:participant) { participants(:traveling_participant2) }

    before do
      t = Time.now - 283.hours
      Timecop.travel(t)
      sign_in_participant participant
      visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}"
    end

    after do
      t = Time.now + 283.hours
      Timecop.travel(t)
    end

    it "displays daily summary information if no accomplished activities are compeleted with 'actual' values" do
      expect(page).to have_text "Average Accomplishment Discrepancy: No activities exist."
    end

    it "displays daily summary information if no pleasureable activities are compeleted with 'actual' values" do
      expect(page).to have_text "Average Pleasure Discrepancy: No activities exist."
    end
  end

  context "Participant with no acitivites is logged in" do
    let(:participant) { participants(:participant3) }

    before do
      sign_in_participant participant
      visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}"
    end

    it "displays an alert if no acitivites were scheduled for a particular day" do
      expect(page).to have_text "No activities were completed during this day."
    end

    it "title is not displayed when a data is selected", :js do
      click_on "Day"
      click_on "Visualize"
      click_on "Last 3 Days"

      expect(page).to_not have_text "3-Day View"
    end

    it "displays an alert if no acitivites were scheduled over a 3-day period", :js do
      expect(page).to_not have_text "3-Day View"
      expect(page).to_not have_text "No activities were completed during this 3-day period."

      click_on "Visualize"
      click_on "Last 3 Days"

      expect(page).to have_text "No activities were completed during this 3-day period."
    end

    it "displays an alert if no acitivites were scheduled over a 7-day period", :js do
      expect(page).to_not have_text "No activities were completed during this 7-day period."

      click_on "Visualize"
      click_on "Last 7 Days"

      expect(page).to have_text "No activities were completed during this 7-day period."
    end
  end

  context "Participant on a day with no activities, but with activies compeleted during the pervious day" do
    let(:participant) { participants(:traveling_participant3) }

    before do
      t = Time.now - 240.hours
      Timecop.travel(t)
      sign_in_participant participant
      visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}"
    end

    after do
      t = Time.now + 240.hours
      Timecop.travel(t)
    end

    it "should see only activities in their timezone" do
      expect(page).to have_text "No activities were completed during this day."
    end
  end
end
