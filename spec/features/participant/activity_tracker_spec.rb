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
    let(:participant2) { participants(:participant2) }
    let(:now) { Time.current }

    before do
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
      with_scope ".container .left.list-group" do
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

      with_scope "#sc-hamburger-menu" do
        click_on "Home"
      end
      visit "/navigator/contexts/DO"
      with_scope ".container .left.list-group" do
        click_on "#1 Awareness"
      end
      click_on "Continue"

      expect(page).to have_text "Last Recorded Awake Period"
      expect(page).to have_text seven_am.to_formatted_s(:date_time_with_meridian)
      expect(page).to have_text eight_pm.to_formatted_s(:date_time_with_meridian)

      click_on "Complete"

      expect(page).to have_text "7am to 8am"
      # ...
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
      with_scope ".container .left.list-group" do
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
      with_scope "#Upcoming_Activities table.table" do
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

      with_scope "#Upcoming_Activities table.table" do
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

    it "correctly calculates pleasure and accomplishment statistics for the viz", :js do
      click_on "Your Activities"

      page.find("#nav_main li:nth-child(3) a").trigger("click")
      # Predicting Your Positive Activities, text not detected by click_on for some reason
      expect(page).to have_text "Predicting Your Positive Activities"
      expect(page).to have_text "Completion score: 0.00%"
      expect(page).to have_text "(You've done 0 out of 1 activity that you scheduled)"
      expect(page).to have_text "Average Pleasure Discrepency: N/A"
      expect(page).to have_text "Average Accomplishment Discrepency: N/A"

      # Modification 1
      Activity.create(
        participant: participants(:participant1),
        activity_type_title: "prancing in the woods",
        start_time: now - 1.hour,
        end_time: now,
        predicted_pleasure_intensity: 10,
        predicted_accomplishment_intensity: 10,
        actual_pleasure_intensity: 0,
        actual_accomplishment_intensity: 0,
        is_complete: true,
        is_scheduled: true
      )

      visit(current_path)
      expect(page).to have_text "You've spent 0 hours (0.00% of total hours) engaged in pleasurable activities!"
      expect(page).to have_text "You've spent 0 hours (0.00% of total hours) engaged in accomplishment activities!"
      page.find("#nav_main li:nth-child(2) a").trigger("click")
      with_scope "div.prancing.in.the.woods" do
        expect(page).to have_text("Pleasure: 0")
        expect(page).to have_text("Accomplishment: 0")
      end

      page.find("#nav_main li:nth-child(3) a").trigger("click")
      expect(page).to have_text "Completion score: 50.00%"
      expect(page).to have_text "(You've done 1 out of 2 activities that you scheduled)"
      expect(page).to have_text "Average Pleasure Discrepency: 10"
      expect(page).to have_text "Average Accomplishment Discrepency: 10"

      # Modification 2
      Activity.create(
        participant: participants(:participant1),
        activity_type_title: "dancing in the street",
        start_time: now - 1.hour,
        end_time: now,
        predicted_pleasure_intensity: 3,
        predicted_accomplishment_intensity: 3,
        actual_pleasure_intensity: 10,
        actual_accomplishment_intensity: 10,
        is_complete: true,
        is_scheduled: true
      )
      visit(current_path)
      expect(page).to have_text "You've spent 1 hour (50.00% of total hours) engaged in pleasurable activities!"
      expect(page).to have_text "You've spent 1 hour (50.00% of total hours) engaged in accomplishment activities!"
      expect(page).to have_text "1 activity you've recorded is high pleasure"
      expect(page).to have_text "1 activity you've recorded is high accomplishment"
      expect(page).to have_text "1 activity you've recorded is both high pleasure and high accomplishment"
      page.find("#nav_main li:nth-child(2) a").trigger("click")
      expect(page).not_to have_selector("div.prancing.in.the.woods", visible: false)
      with_scope "div.in.the" do
        expect(page).to have_text("Pleasure: 5")
        expect(page).to have_text("Accomplishment: 5")
      end
      page.find("#nav_main li:nth-child(3) a").trigger("click")
      expect(page).to have_text "Completion score: 66.67%"
      expect(page).to have_text "(You've done 2 out of 3 activities that you scheduled)"
      expect(page).to have_text "Average Pleasure Discrepency: 8.50"
      expect(page).to have_text "Average Accomplishment Discrepency: 8.50"

      # Modification 3
      Activity.create(
        participant: participants(:participant1),
        activity_type_title: "walking down the lane",
        start_time: now - 1.hour,
        end_time: now,
        predicted_pleasure_intensity: 3,
        predicted_accomplishment_intensity: 3,
        actual_pleasure_intensity: 0,
        actual_accomplishment_intensity: 0,
        is_complete: true,
        is_scheduled: true
      )
      visit(current_path)
      expect(page).to have_text "You've spent 1 hour (33.33% of total hours) engaged in pleasurable activities!"
      expect(page).to have_text "You've spent 1 hour (33.33% of total hours) engaged in accomplishment activities!"
      expect(page).to have_text "1 activity you've recorded is high pleasure"
      expect(page).to have_text "1 activity you've recorded is high accomplishment"
      expect(page).to have_text "1 activity you've recorded is both high pleasure and high accomplishment"
      page.find("#nav_main li:nth-child(2) a").trigger("click")
      expect(page).not_to have_selector("div.prancing.in.the.woods_dancing.in.the.street", visible: false)
      with_scope "div.prancing.in.the.woods_dancing.in.the.street_walking.down.the.lane" do
        expect(page).to have_text("Pleasure: 3")
        expect(page).to have_text("Accomplishment: 3")
      end
      page.find("#nav_main li:nth-child(3) a").trigger("click")
      expect(page).to have_text "Completion score: 75.00%"
      expect(page).to have_text "(You've done 3 out of 4 activities that you scheduled)"
      expect(page).to have_text "Average Pleasure Discrepency: 6.67"
      expect(page).to have_text "Average Accomplishment Discrepency: 6.67"

      # Modification 4
      Activity.create(
        participant: participants(:participant1),
        activity_type_title: "two hour power",
        start_time: now - 3.days - 2.hours,
        end_time: now - 3.days,
        predicted_pleasure_intensity: 9,
        predicted_accomplishment_intensity: 1,
        actual_pleasure_intensity: 10,
        actual_accomplishment_intensity: 0,
        is_complete: true,
        is_scheduled: true
      )
      Activity.create(
        participant: participants(:participant1),
        activity_type_title: "three hour power",
        start_time: now - 2.days - 3.hours,
        end_time: now - 2.days,
        predicted_pleasure_intensity: 10,
        predicted_accomplishment_intensity: 0,
        actual_pleasure_intensity: 10,
        actual_accomplishment_intensity: 0,
        is_complete: true,
        is_scheduled: true
      )
      Activity.create(
        participant: participants(:participant1),
        activity_type_title: "four hour power",
        start_time: now - 1.days - 4.hours,
        end_time: now - 1.days,
        predicted_pleasure_intensity: 0,
        predicted_accomplishment_intensity: 5,
        actual_pleasure_intensity: 10,
        actual_accomplishment_intensity: 0,
        is_complete: true,
        is_scheduled: true
      )
      Activity.create(
        participant: participants(:participant1),
        activity_type_title: "not done",
        start_time: now - 9.days - 4.hours,
        end_time: now - 9.days,
        actual_pleasure_intensity: 10,
        actual_accomplishment_intensity: 10,
        is_complete: false,
        is_scheduled: true
      )
      visit(current_path)
      expect(page).to have_text "You've spent 4 hours (66.67% of total hours) engaged in pleasurable activities!"
      expect(page).to have_text "You've spent 1 hour (16.67% of total hours) engaged in accomplishment activities!"
      expect(page).to have_text "4 activities you've recorded are high pleasure"
      expect(page).to have_text "1 activity you've recorded is high accomplishment"
      expect(page).to have_text "1 activity you've recorded is both high pleasure and high accomplishment"
      page.find("#nav_main li:nth-child(2) a").trigger("click")
      with_scope "div.prancing.in.the.woods_dancing.in.the.street_walking.down.the.lane" do
        expect(page).to have_text("Pleasure: 3")
        expect(page).to have_text("Accomplishment: 3")
      end
      with_scope "div.two.hour.power" do
        expect(page).to have_text("Pleasure: 10")
        expect(page).to have_text("Accomplishment: 0")
      end
      expect(page.all(".bucket").count).to eq(4)
      click_on "3 day view"
      expect(page.all(".bucket").count).to eq(3)
      page.find("#nav_main li:nth-child(3) a").trigger("click")
      expect(page).to have_text "Completion score: 75.00%"
      expect(page).to have_text "(You've done 6 out of 8 activities that you scheduled)"
      expect(page).to have_text "Average Pleasure Discrepency: 5.17"
      expect(page).to have_text "Average Accomplishment Discrepency: 4.33"
    end
  end

  context "Participant with no acitivites is logged in" do
    let(:participant3) { participants(:participant3) }

    before do
      sign_in_participant participant3
      visit "/navigator/modules/656086433"
    end

    it "displays an alert if no acitivites were scheduled for a particular day" do
      expect(page).to have_text "No activities were completed during this day."
    end

    it "displays an alert if no acitivites were scheduled over a 3-day period", :js do
      expect(page).to_not have_text "No activities were completed during this 3-day period."

      click_on "3-Day"

      expect(page).to have_text "No activities were completed during this 3-day period."
    end

    it "displays an alert if no acitivites were scheduled over a 7-day period", :js do
      expect(page).to_not have_text "No activities were completed during this 7-day period."

      click_on "7-Day"

      expect(page).to have_text "No activities were completed during this 7-day period."
    end
  end
end
