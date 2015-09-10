require "rails_helper"

feature "patient dashboard", type: :feature do
  fixtures :arms, :users, :user_roles, :participants, :"bit_core/slideshows",
           :"bit_core/slides", :"bit_core/tools", :"bit_core/content_modules",
           :"bit_core/content_providers", :coach_assignments, :messages, :groups,
           :memberships, :tasks, :task_status, :moods, :phq_assessments,
           :emotions, :delivered_messages, :thought_patterns, :thoughts,
           :activity_types, :activities, :emotional_ratings,
           :media_access_events

  describe "Logged in as a clinician" do
    let(:clinician) { users(:clinician1) }
    let(:time_now) { Time.current }
    let(:short_timestamp) { time_now.to_s(:standard) }
    let(:longer_timestamp) { time_now.to_s(:standard) }
    let(:participant1) { participants(:participant1) }
    let(:participant_for_arm1_group1) { participants(:participant_for_arm1_group1) }
    let(:participant_study_complete) { participants(:participant_study_complete) }
    let(:group1) { groups(:group1) }
    let(:group2) { groups(:group2) }

    context "Coach views table with many patients with phq features" do
      before do
        allow(Rails.application.config).to receive(:include_phq_features)
          .and_return(true)
        allow(Rails.application.config).to receive(:include_social_features)
          .and_return(false)
        sign_in_user clinician
        visit "/coach/groups/#{group1.id}/patient_dashboards"
      end

      it "should display phq details" do
        within "#patient-#{participants(:participant_phq1).id}-details" do
          expect(page).to have_text("Patient: SCTest01")
          expect(page).to have_text("Suggestion: Stay on i-CBT")
          expect(page).to have_text("Legend")
          expect(page).to have_text("PHQ9 assessment missing this week - values copied from previous assessment.")
          expect(page).to have_text("PHQ9 assessment missing this week - no previous assessment data to copy from.")
          expect(page).to have_text("PHQ9 assessment missing answers for up to 3 questions - using 1.5 to fill them in.")
          expect(page).to have_text("PHQ9 assessment missing answers for more than 3 questions - data unreliable")
          expect(page).to have_text("N/A")
        end
      end

      it "should move a patient to the stepped table when stepped" do
        expect(page).to have_text "Stepped Patients"
        expect(page).to have_text "Not Stepped Patients"

        within "#patients" do
          expect(page).to have_text "Step to t-CBT?"
          expect(page).to have_button "Details"
          expect(page).to have_text "SCTest01"
        end
        within "#stepped-patients" do
          expect(page).to_not have_text "SCTest01"
        end

        within "#patient-#{participants(:participant_phq1).id}" do
          click_on "Step"
        end

        within "#patients" do
          expect(page).to_not have_text "SCTest01"
        end
        within "#stepped-patients" do
          expect(page).to_not have_text "Step to t-CBT?"
          expect(page).to_not have_button "Details"
          expect(page).to have_text "SCTest01"
        end
      end

      it "does sees correct columns in active and inactive patient views" do
        within "#patients" do
          expect(page).not_to have_text "Stepped on Date"
          expect(page).to have_text "Step to t-CBT"
        end

        within "#stepped-patients" do
          expect(page).to have_text "Stepped on Date"
          expect(page).not_to have_text "Step to t-CBT"
        end

        click_on "Inactive Patients"
        within "#patients" do
          expect(page).not_to have_text "Stepped on Date"
          expect(page).not_to have_text "Step to t-CBT"
        end

        within "#stepped-patients" do
          expect(page).to have_text "Stepped on Date"
          expect(page).not_to have_text "Step to t-CBT"
        end
      end
    end

    context "Coach views active and inactive patients without phq features" do
      before do
        allow(Rails.application.config).to receive(:include_phq_features)
          .and_return(false)
        sign_in_user clinician
        visit "/coach/groups/#{group1.id}/patient_dashboards"
      end

      it "does sees correct columns in active and inactive patient views" do
        expect(page).not_to have_css "#stepped-patients"
        within "#patients" do
          expect(page).not_to have_text "Stepped on Date"
          expect(page).not_to have_text "Step to t-CBT"
        end

        click_on "Inactive Patients"
        expect(page).not_to have_css "#stepped-patients"
        within "#patients" do
          expect(page).not_to have_text "Stepped on Date"
          expect(page).not_to have_text "Step to t-CBT"
        end
      end
    end

    context "Authorization" do
      before do
        sign_in_user users :user2
      end

      it "should only display patients they are assigned and are of a group" do
        visit "/coach/groups/#{group1.id}/patient_dashboards"

        expect(page).to have_text("participant_for_arm1_group1")
        expect(page).not_to have_text("TFD-1111")

        sign_in_user clinician
        visit "/coach/groups/#{group1.id}/patient_dashboards"

        expect(page).not_to have_text("participant_for_arm1_group1")
        expect(page).to have_text("TFD-1111")
      end

      it "should only be able to view patient data they are assigned to" do
        expect(Rails.application.config).to receive(:study_length_in_weeks).at_least(2).times { 8 }
        visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant_for_arm1_group1.id}"

        expect(page).to have_text("Participant participant_for_arm1_group1")
        expect(page).not_to have_text("You are not authorized to access this page")

        sign_in_user clinician
        visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant_for_arm1_group1.id}"

        expect(page).to_not have_text("Participant participant_for_arm1_group1")
        expect(page).to have_text("You are not authorized to access this page")
      end

      it "should have button to view active patients on inactive view" do
        visit "/coach/groups/#{group1.id}/patient_dashboards?active=false"

        expect(page).to have_text("Active Patients")
        expect(page).to_not have_button("Step")
      end
    end

    context "Coach visits discontinued patient" do
      before do
        sign_in_user users(:clinician1)
        expect(Rails.application.config).to receive(:study_length_in_weeks).at_least(2).times { 8 }
        visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant_study_complete.id}"
      end

      it "displays inactive status" do
        expect(page).to have_text("Participant #{participant_study_complete.study_id}")
        expect(page).to have_text("Inactive")
      end
    end

    context "Coach visits active patient" do
      before do
        Timecop.travel(DateTime.now.beginning_of_minute)
        sign_in_user users(:clinician1)
        expect(Rails.application.config).to receive(:study_length_in_weeks).at_least(2).times { 8 }
        visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant1.id}"
      end

      it "displays active status" do
        expect(page).to have_text("Participant TFD-1111")
        expect(page).to have_text("Active")
        expect(page).to have_text("Currently in week 1")
      end

      it "summarizes messages" do
        expect(page).to have_the_table(
          id: "messages",
          cells: ["I like this app", time_now.to_s(:standard)]
        )
      end

      it "summarizes logins" do
        Timecop.travel(DateTime.now.beginning_of_minute) do
          sign_in_participant participant1
          sign_in_user clinician
          visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant1.id}"

          expect(page).to have_the_table(
            id: "logins",
            cells: [short_timestamp]
          )
          expect(page).to have_xpath "//p[@id = 'login-count' and contains(., 'Total: 1')]"
        end
      end

      it "summarizes logins in during this treatment week" do
        sign_in_participant participant1
        Timecop.travel(Time.zone.now + 2.days) do
          sign_in_participant participant1
          sign_in_user clinician
          visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant1.id}"
          expect(page).to have_content "Logins during this treatment week: 2"
          Timecop.travel(Time.zone.now + 6.days) do
            sign_in_user clinician
            visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant1.id}"
            expect(page).to have_content "Logins during this treatment week: 0"
          end
        end
      end

      it "summarizes moods" do
        expect(page).to have_the_table(
          id: "moods-table",
          cells: ["9", (Time.current - 28.days).to_s(:standard)]
        )
        expect(page).to have_the_table(
          id: "moods-table",
          cells: ["5", (Time.current - 21.days).to_s(:standard)]
        )
      end

      it "links to the activities visualization" do
        find("h3 a", text: "Activities visualization").click

        expect(page).to have_content "Daily Averages for"
      end

      it "links to the thoughts visualization" do
        find("h3 a", text: "Thoughts visualization").click
      end

      it "summarizes future activities" do
        expect(page).to have_the_table(
          id: "activities_future",
          cells: [
            "Going to school",
            "Not Rated",
            "Not Rated",
            "Unscheduled",
            short_timestamp
          ]
        )
      end

      it "summarizes past activities" do
        Timecop.travel(DateTime.now.beginning_of_minute) do
          expect(page).to have_the_table(
            id: "activities_past",
            cells: [
              "Loving",
              "Planned",
              "Not Rated",
              "Not Rated",
              "Scheduled for #{ (Time.current - 4.hour).to_s(:standard) }",
              short_timestamp
            ]
          )
        end
      end

      it "distinguishes between monitored and planned activities", :js do
        Timecop.travel(time_now) do
          sign_in_participant participants(:participant1)
          visit "/navigator/contexts/DO"
          click_on "#1 Awareness"
          click_on "Next"
          yesterday_str = Date.yesterday.strftime("%a")
          select "#{ yesterday_str } 12 AM", from: "About what time did you wake up? It's okay if this isn't exact."
          select "#{ yesterday_str } 1 AM", from: "About what time did you go to sleep? This doesn't need to be exact either."
          click_on "Create"

          expect(page).to have_text("How much pleasure")

          fill_in "What did you do from 12 am to 1 am?", with: "run"
          click_on "Next"
          sign_in_user users(:clinician1)

          visit "/coach/groups/#{group1.id}/patient_dashboards/#{participants(:participant1).id}"

          expect(page).to have_the_table(
            id: "activities_past",
            cells: [
              "run",
              "Monitored",
              "Not Rated",
              "Not Rated",
              "0",
              "0",
              "Scheduled for #{ (time_now - 2.hour).to_s(:standard) }",
              short_timestamp
            ]
          )
        end
      end

      it "summarizes thoughts" do
        expect(page).to have_the_table(
          id: "thoughts",
          cells: [
            "I am a magnet for birds",
            "Labeling and Mislabeling",
            "Birds have no idea what they are doing",
            "It was nature",
            participant1.thoughts.last.created_at.to_s(:standard)
          ]
        )
      end

      it "summarizes feelings" do
        expect(page).to have_the_table(
          id: "emotions-table",
          cells: ["longing", longer_timestamp]
        )
      end

      it "summarizes tasks" do
        expect(page).to have_the_table(
          id: "task_statuses",
          cells: ["#1 Awareness", Date.today.strftime("%m/%d/%Y"), "Incomplete"]
        )

        expect(page).to have_the_table(
          id: "task_statuses",
          cells: ["Add a New Harmful Thought", Date.today.strftime("%m/%d/%Y"), "Incomplete"]
        )
      end

      it "should see end date if study weeks is configured" do
        expect(page).to have_text("8 weeks from the start date is:")
      end
    end

    context "Coach visits inactive patient" do
      let(:inactive_participant) { participants(:inactive_participant) }

      before do
        allow(Rails.application.config).to receive(:include_social_features)
          .and_return(false)
        sign_in_user clinician
      end

      it "displays number of unread messages" do
        visit "/coach/groups/#{group1.id}/patient_dashboards"
        within "#patient-#{ participant1.id } .unread" do
          expect(page).to have_text("1")
        end
        visit "/coach/groups/#{group1.id}/messages"

        expect(page).to have_text("Inbox (2)")

        click_on "I like this app"

        visit "/coach/groups/#{group1.id}/patient_dashboards"

        within "#patient-#{ participant1.id } .unread" do
          expect(page).to have_text("0")
        end

        visit "/coach/groups/#{group1.id}/messages"

        expect(page).to have_text("Inbox (1)")
      end
    end
  end
end
