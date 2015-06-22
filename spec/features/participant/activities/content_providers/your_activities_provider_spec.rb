require "rails_helper"

feature "Activities", type: :feature do
  fixtures :all

  describe "When in Your Activities" do
    describe "ContentProvider::YourActivitiesProvider" do
      context "Participant with activities on days more than 3 days ago" do
        let(:participant) { participants(:seasoned_participant) }

        before do
          Timecop.return
          Membership.create!(
            participant: participant,
            group: groups(:group1),
            start_date: Time.zone.today.advance(days: -7),
            end_date: Time.zone.today.advance(days: 7))
          Activity.create!(
            participant: participant,
            activity_type: activity_types(:sleeping),
            predicted_accomplishment_intensity: 1,
            predicted_pleasure_intensity: 2,
            actual_accomplishment_intensity: 6,
            actual_pleasure_intensity: 7,
            start_time: Time.zone.now - 120.hours,
            end_time: Time.zone.now - 119.hours)
          sign_in_participant participants(:seasoned_participant)
          visit "/navigator/modules/#{bit_core_content_modules(:do_your_activities_viz).id}"
        end

        it "alerts are correctly displayed", :js do
          click_on "Day"
          click_on "Visualize"
          click_on "Last 3 Days"

          expect(page).to have_text "Notice! No activities were completed during this 3-day period."

          click_on "Day"
          click_on "Visualize"
          click_on "Last 7 Days"

          expect(page).to have_text "7-Day View"
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
          expect(page).to have_text "Average Accomplishment Discrepancy: 1.0"
          expect(page).to have_text "Average Pleasure Discrepancy: 1.0"
        end

        it "displays daily completion information of only scheduled activities" do
          reviewed_and_complete = participant.activities.for_day(Time.now).reviewed_and_complete
          were_planned = participant.activities.for_day(Time.now).were_planned

          expect(page).to have_text "Completion Score: 67% (You completed #{reviewed_and_complete.count} out of #{were_planned.count} activities that you scheduled.)"
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

        it "allows for the updating of a past activity", :js do
          page.all("a", text: "Working")[1].click

          expect(page).to have_text "Predicted Average Importance: 6 Kind of fun: 5"
          expect(page).to have_text "Actual  Not answered: Not answered:"
          expect(page).to have_text "Difference N/A N/A"

          within "form#edit_activity_#{activity.id}" do
            click_on "Edit"
            execute_script("$('.pleasure-container input:first').trigger('click')")
            execute_script("$('.accomplishment-container input:first').trigger('click')")
            execute_script("$('.panel-footer input.btn-primary').trigger('click')")
          end

          expect(page).to have_text "Activity updated"
          expect(page).to have_text "Accomplishment: 0 · Pleasure: 0"

          page.all("a", text: "Working")[1].click

          expect(page).to have_text "Predicted  Average Importance: 6 Kind of fun: 5"
          expect(page).to have_text "Actual Low Importance: 0 Not Fun: 0"
          expect(page).to have_text "Difference  6  5"
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

      context "Participant on a day with no activities, but with activities compeleted during the previous day" do
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
    end
  end
end
