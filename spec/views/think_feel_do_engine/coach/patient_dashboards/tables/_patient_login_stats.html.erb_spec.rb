require "rails_helper"

module SocialNetworking
  RSpec.describe "think_feel_do_engine/coach/patient_dashboards"\
                 "/tables/_patient_login_stats.html.erb",
                 type: :view do
    describe "summarizes login information" do
      let(:participant) do
        instance_double(
          Participant,
          sign_in_count: "foo",
          current_sign_in_at: Time.zone.now + 34.day,
          latest_action_at: Time.zone.now + 23.months,
          duration_of_last_session: 100)
      end
      let(:membership) do
        instance_double(
          Membership,
          logins_today: [],
          week_in_study: 1,
          logins_by_week: "bar")
      end

      before do
        assign :participant, participant
        allow(view).to receive(:view_membership) { membership }
      end

      describe "when events exist for the participant" do
        before do
          allow(participant).to receive(:events) { [double("event")] }
          render partial: "think_feel_do_engine/coach/patient_dashboards"\
                 "/tables/patient_login_stats"
        end

        it "formats the last sign in at" do
          expect(rendered)
            .to have_text participant.current_sign_in_at.to_s(:standard_with_day_of_week)
        end

        it "displays number of logins today" do
          expect(rendered)
            .to have_text "foo"
        end

        it "displays logins by week" do
          expect(rendered)
            .to have_text "bar"
        end

        it "formats the last activity detected" do
          expect(rendered)
            .to have_text participant.latest_action_at.to_s(:standard_with_day_of_week)
        end

        it "formats duration of last session" do
          expect(rendered)
            .to have_text "2 minutes"
        end
      end

      describe "when no events exist for the participant" do
        before do
          allow(participant).to receive(:current_sign_in_at)
          allow(participant).to receive(:events) { [] }
          render partial: "think_feel_do_engine/coach/patient_dashboards"\
                 "/tables/patient_login_stats"
        end

        it "displays last login message" do
          expect(rendered)
            .to have_text "Never Logged In"
        end

        it "displays last activity message" do
          expect(rendered)
            .to have_text "Participant has no events to report."
        end

        it "displays duration of last session message" do
          expect(rendered)
            .to have_text "Not available because participant has no events to report."
        end
      end
    end
  end
end
