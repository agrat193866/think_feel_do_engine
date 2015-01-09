require "spec_helper"

feature "patient dashboard", type: :feature do
  fixtures(
    :arms, :users, :user_roles, :participants, :"bit_core/slideshows",
    :"bit_core/slides", :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :coach_assignments, :messages, :groups,
    :memberships, :tasks, :task_status, :moods, :phq_assessments, :emotions,
    :delivered_messages, :thought_patterns, :thoughts, :activity_types,
    :activities, :emotional_ratings
  )

  describe "Logged in as a clinician" do
    let(:time_now) { Time.current }
    let(:short_timestamp) { time_now.to_formatted_s(:short) }
    let(:longer_timestamp) { time_now.to_formatted_s(:date_time_with_meridian) }
    let(:participant1) { participants(:participant1) }
    let(:participant_for_arm1_group1) { participants(:participant_for_arm1_group1) }
    let(:group1) { groups(:group1) }
    let(:group2) { groups(:group2) }

    context "Coach views table with many patients" do
      before do
        sign_in_user users :clinician1
        visit "/coach/groups/#{group1.id}/patient_dashboards"
      end

      it "should display all messages" do
        expect(page).not_to have_text("participant1#example.com")
        expect(page).to have_the_table(
          id: "patients",
          cells: [
            "TFD-1111",
            1,
            1,
            "PHQ-9 WARNING 15 on " +
            participant1.phq_assessments.last.release_date.to_s(:brief_date),
            "No; Too Early",
            0,
            "Never Logged In"
          ]
        )
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

        sign_in_user users :clinician1
        visit "/coach/groups/#{group1.id}/patient_dashboards"

        expect(page).not_to have_text("participant_for_arm1_group1")
        expect(page).to have_text("TFD-1111")
      end

      it "should only be able to view patient data they are assigned to" do
        visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant_for_arm1_group1.id}"

        expect(page).to have_text("Participant participant_for_arm1_group1")
        expect(page).not_to have_text("You are not authorized to access this page")

        sign_in_user users :clinician1
        visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant_for_arm1_group1.id}"

        expect(page).to_not have_text("Participant participant_for_arm1_group1")
        expect(page).to have_text("You are not authorized to access this page")
      end
    end

    context "Coach visits active patient" do
      before do
        sign_in_user users(:clinician1)
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
          cells: ["I like this app", Date.current]
        )
      end

      it "summarizes logins" do
        sign_in_participant participant1
        sign_in_user users :clinician1
        visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant1.id}"

        expect(page).to have_the_table(
          id: "logins",
          cells: [short_timestamp]
        )
        expect(page).to have_xpath "//p[@id = 'login-count' and contains(., 'Total: 1')]"
      end

      it "summarizes learning when not completed learning", :js do
        Timecop.travel(time_now) do
          visit "/coach/groups/#{group1.id}/patient_dashboards/#{ participant1.id }"

          within_table "learning_data" do
            expect(page).to_not have_text "Not Completed"
            expect(page).to have_text "No data available in table"
          end

          sign_in_participant participant1

          page.find(".LEARN.hidden-xs a").trigger("click")

          expect(page).to have_text("Lessons")

          page.find(".list-group-item", text: "Do - Awareness Introduction").trigger("click")
          sign_in_user users(:clinician1)
          visit "/coach/groups/#{group1.id}/patient_dashboards/#{ participant1.id }"

          expect(page).to have_the_table(
            id: "learning_data",
            cells: ["Do - Awareness Introduction", short_timestamp, short_timestamp, "Not Completed", "Not Completed"]
          )
        end
        Timecop.return
      end

      it "summarizes learning when completed learning", :js do
        Timecop.travel(time_now) do
          visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant1.id}"

          within_table "learning_data" do
            expect(page).to_not have_text "Not Completed"
            expect(page).to have_text "No data available in table"
          end

          sign_in_participant participant1
          page.find(".LEARN.hidden-xs a").trigger("click")
          page.find(".list-group-item.task-status", text: "Do - Awareness Introduction").trigger("click")
          click_on "Continue"

          sign_in_user users :clinician1
          visit "/coach/groups/#{group1.id}/patient_dashboards/#{participant1.id}"
          expect(page).to have_the_table(
            id: "learning_data",
            cells: ["Do - Awareness Introduction", short_timestamp, short_timestamp, short_timestamp, "less than a minute"]
          )
        end
        Timecop.return
      end

      it "summarizes moods" do
        expect(page).to have_the_table(
          id: "moods",
          cells: ["9", (Time.current - 28.days).to_formatted_s(:date_time_with_meridian)]
        )
        expect(page).to have_the_table(
          id: "moods",
          cells: ["5", (Time.current - 21.days).to_formatted_s(:date_time_with_meridian)]
        )
      end

      it "summarizes phq9 assessments" do
        expect(page).to have_the_table(
          id: "phq_assessments",
          cells: [15, 2, 1, 2, 2, 0, 2, 2, 1, "PHQ-9 WARNING: 3"]
            .push("Released #{ Date.yesterday }")
            .push("Created #{ Date.current }")
        )
      end

      it "links to the activities visualization" do
        expect(page).to have_content "Activities visualization"
      end

      it "links to the thoughts visualization" do
        expect(page).to have_content "Thoughts visualization"
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
        expect(page).to have_the_table(
          id: "activities_past",
          cells: [
            "Loving",
            "Planned",
            "Not Rated",
            "6",
            "Not Rated",
            "Scheduled for #{ (Time.current - 1.hour).to_formatted_s(:short) }",
            short_timestamp
          ]
        )
      end

      it "destinguishes between monitored and planned activities", :js do
        Timecop.travel(time_now) do
          sign_in_participant participants(:participant1)
          visit "/navigator/contexts/DO"
          click_on "#1 Awareness"
          click_on "Continue"
          yesterday_str = Date.yesterday.strftime("%a")
          select "#{ yesterday_str } 12 AM", from: "About what time did you wake up? It's okay if this isn't exact."
          select "#{ yesterday_str } 1 AM", from: "About what time did you go to sleep? This doesn't need to be exact either."
          click_on "Create"

          expect(page).to have_text("How much pleasure")

          fill_in "What did you do from 12am to 1am?", with: "run"
          click_on "Continue"
          # expect(page).to have_text("Take a look - does this all seem right?")
          sign_in_user users(:clinician1)
          visit "/coach/groups/#{group1.id}/patient_dashboards"
          click_on "TFD-1111"

          expect(page).to have_the_table(
            id: "activities_past",
            cells: [
              "run",
              "Monitored",
              "Completed",
              "Not Rated",
              "Not Rated",
              "Not Rated",
              "Not Rated",
              "Scheduled for #{ (time_now - 1.hour).to_formatted_s(:short) }",
              short_timestamp
            ]
          )
        end
        Timecop.return
      end

      it "summarizes thoughts" do
        expect(page).to have_the_table(
          id: "thoughts",
          cells: [
            "I am a magnet for birds",
            "harmful",
            "Labeling and Mislabeling",
            "Birds have no idea what they are doing",
            "It was nature",
            participant1.thoughts.last.created_at.to_formatted_s(:date_time_with_meridian)
          ]
        )
      end

      it "summarizes feelings" do
        expect(page).to have_the_table(
          id: "emotions",
          cells: ["longing", longer_timestamp]
        )
      end

      it "summarizes tasks" do
        expect(page).to have_the_table(
          id: "task_statuses",
          cells: ["#1 Awareness", short_timestamp, "Incomplete"]
        )
        expect(page).to have_the_table(
          id: "task_statuses",
          cells: ["Add a New Thought", short_timestamp, "Incomplete"]
        )
      end
    end

    context "Coach visits inactive patient" do
      let(:inactive_participant) { participants(:inactive_participant) }

      before do
        sign_in_user users :clinician1
      end

      it "displays number of unread messages" do
        visit "/coach/groups/#{group1.id}/patient_dashboards"
        with_scope "#patient-#{ participant1.id } .unread" do
          expect(page).to have_text("1")
        end
        visit "/coach/groups/#{group1.id}/messages"

        expect(page).to have_text("Inbox (1)")

        click_on "I like this app"

        visit "/coach/groups/#{group1.id}/patient_dashboards"

        with_scope "#patient-#{ participant1.id } .unread" do
          expect(page).to have_text("0")
        end

        visit "/coach/groups/#{group1.id}/messages"

        expect(page).to have_text("Inbox (0)")
      end

      it "displays participant's 'Active' status on index page" do
        visit "/coach/groups/#{group2.id}/patient_dashboards"

        expect(page).to have_text("Inactive")
      end

      it "displays participant's 'Inactive' status on their 'show' page" do
        visit "/coach/groups/#{group2.id}/patient_dashboards/#{inactive_participant.id }"

        expect(page).to have_text("Participant TFD-inactive")
        expect(page).to have_text("Inactive")
        expect(page).to have_text("Study has been Completed")
      end
    end

    it "should allow a coach to set the membership end date" do
      sign_in_user users :clinician1
      visit "/coach/groups/#{group1.id}/patient_dashboards"

      expect(page).to_not have_text("Membership successfully updated")

      click_on "End Now"

      expect(page).to have_text("Membership successfully updated")
    end
  end
end
