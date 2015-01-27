require "spec_helper"

feature "activity tracker", type: :feature do
  fixtures(
    :participants, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :users, :arms,
    :"bit_core/content_modules", :"bit_core/content_providers",
    :activity_types, :activities, :groups, :memberships, :tasks, :task_status
  )

  context "Participant1 is logged in" do
    let(:participant1) { participants(:participant1) }

    before do
      Time.zone = "Central Time (US & Canada)"
      sign_in_participant participant1
      visit "/navigator/contexts/DO"
    end

    it "implements #1 Awareness", :js do
      page.find(".container .left.list-group .list-group-item", text: "#1 Awareness").trigger("click")

      expect(page).to have_text(bit_core_slides(:do_awareness_intro1).body)
      find(".btn", text: "Continue").trigger("click")

      expect(page).to have_text("OK, let's talk about yesterday.")

      yesterday_str = Date.yesterday.strftime("%a")
      select "#{ yesterday_str } 12 AM",
             from: "About what time did you wake up? It's okay if this isn't " \
                   "exact."
      select "#{ yesterday_str } 4 AM",
             from: "About what time did you go to sleep? This doesn't need " \
                   "to be exact either."
      click_on "Create"

      expect(page).to have_text("Review Your Day")

      find("#activity_type_0").trigger("click")
      fill_in("activity_type_0", with: "ate cheeseburgers")
      choose_rating("pleasure_0", 9)
      choose_rating("accomplishment_0", 4)

      find("#activity_type_1").trigger("click")
      fill_in("activity_type_1", with: "ate bad cheeseburgers")
      choose_rating("pleasure_1", 0)
      choose_rating("accomplishment_1", 0)

      find("#copy_2").trigger("click")

      find("#activity_type_3").trigger("click")
      fill_in("activity_type_3", with: "ate bad cheeseburgers")
      choose_rating("pleasure_3", 0)
      choose_rating("accomplishment_3", 1)
      find('button#submit_activities[type="submit"]').click

      expect(page).to have_text("ate cheeseburgers")
      expect(page).to have_text("ate bad cheeseburgers", count: 3)

      find(".btn", text: "Continue").trigger("click")

      expect(page).to have_text("Things you found fun.")
      expect(page).to have_text("ate cheeseburgers")

      find(".btn", text: "Continue").trigger("click")

      expect(page).to have_text("Things that make you feel like you've accomplished something.")
      expect(page).not_to have_text("ate cheeseburgers")

      find(".btn", text: "Continue").trigger("click")
      expect(page).to have_text("#2 Planning")
    end

    it "displays most recent unaccounted activity" do
      within ".container .left.list-group" do
        click_on "#1 Awareness"
      end
      click_on "Continue"

      expect(page).to_not have_text "Last Recorded Awake Period"

      four_am = Time.local(2014, "jan", 1, 4)
      five_pm = Time.local(2014, "jan", 1, 17)

      seven_am = Time.local(2014, "jan", 2, 7)
      eight_pm = Time.local(2014, "jan", 2, 20)

      awake_period = participant1.awake_periods.build(start_time: four_am, end_time: five_pm)
      awake_period.save!

      awake_period = participant1.awake_periods.build(start_time: seven_am, end_time: eight_pm)
      awake_period.save!

      within "#sc-hamburger-menu" do
        click_on "Home"
      end
      visit "/navigator/contexts/DO"
      within ".container .left.list-group" do
        click_on "#1 Awareness"
      end
      click_on "Continue"

      expect(page).to have_text "Last Recorded Awake Period"
      expect(page).to have_text seven_am.to_formatted_s(:date_time_with_meridian)
      expect(page).to have_text eight_pm.to_formatted_s(:date_time_with_meridian)

      click_on "Complete"

      expect(page).to have_text "7am to 8am"
      expect(page).to have_text "7pm to 8pm"
    end

    it "implements #2 Planning", :js do
      page.find(".list-group-item", text: "#2 Planning").trigger("click")

      expect(page).to have_text "The last few times you were here..."

      click_on "Continue"

      expect(page).to have_text("We want you to plan one fun thing")

      find("input[value='Loving'][type='radio']").click
      find("input#future_date_picker_0").click
      find("#ui-datepicker-div .ui-datepicker-today a").click
      choose_rating "pleasure_0", 10
      choose_rating "accomplishment_0", 10
      click_on "Continue"
      choose_rating "pleasure_0", 10
      choose_rating "accomplishment_0", 10

      expect(page).to have_text("Now, plan something that gives you a sense of accomplishment.")

      fill_in "activity_activity_type_new_title", with: "Parkour"
      click_on "Continue"

      expect(page.body).to have_text("OK... the most important thing")

      click_on "Continue"

      expect(page).to have_text("Your Planned Activities")

      click_on "Continue"

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

      click_on "Continue"

      expect(page).to have_text(bit_core_slides(:do_doing_intro2).title)

      click_on "Continue"

      expect(page).to have_text("You said you were going to")
      expect(page).to have_text("Loving")
    end

    it "creates new accomplishable and/or pleasurable activities via radio", :js do
      click_on "Add a New Activity"

      expect(page).to have_text("Choose one")

      find("input[value='Loving'][type='radio']").click
      choose_rating "pleasure_0", 10
      choose_rating "accomplishment_0", 10
      click_on "Continue"

      expect(page).to have_text("Activity saved")
      within "#Upcoming_Activities table.table" do
        expect(page).to have_text "Loving"
        expect(page).to have_text((Time.current + 1.hour).to_s(:date_time_with_meridian))
        expect(page).to have_text "Really fun (10)"
        expect(page).to have_text "High Importance (10)"
      end
    end

    it "creates new accomplishable and/or pleasurable activities input text field", :js do
      click_on "Add a New Activity"
      fill_in "Or add another", with: "Eating!"
      choose_rating "pleasure_0", 10
      choose_rating "accomplishment_0", 10
      click_on "Continue"

      expect(page).to have_text("Activity saved")

      within "#Upcoming_Activities table.table" do
        expect(page).to have_text "Eating!"
        expect(page).to have_text((Time.current + 1.hour).to_s(:date_time_with_meridian))
        expect(page).to have_text "Really fun (10)"
        expect(page).to have_text "High Importance (10)"
      end
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
      click_on "Continue"

      expect(page).to have_text "Activity saved"
      expect(page).to have_text "Good Work!"

      click_on "Continue"

      expect(page).to have_text "#1 Awareness"
      expect(page).to_not have_text "Recent Past Activities"
      expect(page).to_not have_text "Loving"
      expect(page).to_not have_text "Parkour"
      expect(page).to_not have_link "Edit"
    end
  end

  context "Participant with activities is logged in" do
    let(:participant) { participants(:traveling_participant1) }
    let(:activity) { activities(:p2_activity_1_hr_ago) }

    before do
      Time.zone = "Central Time (US & Canada)"
      t = DateTime.new(2015, 1, 15, 10)
      Timecop.travel(t)
      sign_in_participant participant
      visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}"
    end

    after do
      Timecop.return
    end

    it "displays daily activity averages" do
      expect(page).to have_text "Daily Averages for Jan 15, 2015"
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
      visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}?date=14/1/2015"

      expect(page).to have_text "Daily Averages for Jan 14, 2015"
      expect(page).to_not have_text "Daily Averages for Jan 15, 2015"

      click_on "Today"

      expect(page).to have_text "Daily Averages for Jan 15, 2015"
    end

    it "displays a list of activities and activity details" do
      expect(page).to have_text "8 am - 9 am: Eating breakfast"
      expect(page).to have_text "Accomplishment: 9 · Pleasure: 9"

      expect(page).to have_text "Accomplishment  Pleasure"
      expect(page).to have_text "Predicted High Importance: 10 Really fun: 10"
      expect(page).to have_text "Actual  High Importance: 9  Really fun: 9"
      expect(page).to have_text "Difference  1  1"
      expect(page).to have_text "9 am - 10 am: Working"
      expect(page).to have_text "Accomplishment: 2 · Pleasure: 2"

      expect(page).to have_text "10 am - 11 am: Working"
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
      expect(page).to have_text "10 am - 11 am: Working"

      expect(page).to_not have_text "Predicted Average Importance: 6 Kind of fun: 5"
      expect(page).to_not have_text "Actual  Not answered: Not answered:"
      expect(page).to_not have_text "Difference N/A N/A"

      click_on "10 am - 11 am: Working"

      expect(page).to have_text "Predicted Average Importance: 6 Kind of fun: 5"
      expect(page).to have_text "Actual  Not answered: Not answered:"
      expect(page).to have_text "Difference N/A N/A"

      within "form#edit_activity_#{activity.id}" do
        expect(page).to_not have_button "Update"
        expect(page).to_not have_button "Cancel"

        click_on "Edit"

        expect(page).to have_button "Cancel"

        select "1", from: "Actual accomplishment intensity"
        select "8", from: "Actual pleasure intensity"
        click_on "Update"
      end

      expect(page).to_not have_button "Update"
      expect(page).to_not have_button "Cancel"
      expect(page).to have_text "Accomplishment: 1 · Pleasure: 8"

      click_on "10 am - 11 am: Working"

      expect(page).to have_text "Predicted  Average Importance: 6 Kind of fun: 5"
      expect(page).to have_text "Actual  Low Importance: 1 Really fun: 8"
      expect(page).to have_text "Difference  5  3"
    end

    it "allows for the paginating to the previous day's activities" do
      expect(page).to_not have_text "3 pm - 2 pm: Working"
      expect(page).to_not have_text "Accomplishment: 8 · Pleasure: 9"
      expect(page).to_not have_text "Predicted Low Importance: 1 Not Fun: 2"
      expect(page).to_not have_text "Actual  High Importance: 8  Really fun: 9"
      expect(page).to_not have_text "Difference  7 7"

      click_on "Previous Day"

      expect(page).to have_text "3 pm - 2 pm: Working"
      expect(page).to have_text "Accomplishment: 8 · Pleasure: 9"
      expect(page).to have_text "Predicted Low Importance: 1 Not Fun: 2"
      expect(page).to have_text "Actual  High Importance: 8  Really fun: 9"
      expect(page).to have_text "Difference  7 7"
    end

    it "allows for the paginating to the next day's activities" do
      expect(page).to_not have_text "1 pm - 2 pm: Working"
      expect(page).to_not have_text "Predicted High Importance: 8 Kind of fun: 4"

      click_on "Next Day"

      expect(page).to have_text "1 pm - 2 pm: Working"
      expect(page).to have_text "Predicted High Importance: 8 Kind of fun: 4"
      expect(page).to have_text "Actual  Not answered: Not answered:"
      expect(page).to have_text "Difference  N/A N/A"
    end
  end

  context "Participant with no predictions for acitivites is logged in" do
    let(:participant) { participants(:traveling_participant2) }

    before do
      Time.zone = "Central Time (US & Canada)"
      t = DateTime.new(2015, 1, 15, 20)
      Timecop.travel(t)
      sign_in_participant participant
      visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}"
    end

    after do
      Timecop.return
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
      Time.zone = "Central Time (US & Canada)"
      t = DateTime.new(2015, 1, 17, 1)
      Timecop.travel(t)
      sign_in_participant participant
      visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}?date=16/01/2015"
    end

    after do
      Timecop.return
    end

    it "should see only activities in their timezone" do
      expect(page).to have_text "No activities were completed during this day."
    end
  end
end
