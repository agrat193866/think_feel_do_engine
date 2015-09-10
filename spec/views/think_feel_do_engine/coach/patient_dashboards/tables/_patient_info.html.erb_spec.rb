require "rails_helper"

module SocialNetworking
  RSpec.describe "think_feel_do_engine/coach/patient_dashboards"\
                 "/tables/_patient_info.html.erb",
                 type: :view do
    describe "profile info summary" do
      NUMBER_OF_WEEKS = 2
      let(:participant) { instance_double(Participant) }
      let(:membership) do
        instance_double(
          Membership,
          day_in_study: 8,
          lessons_read_for_week: [],
          start_date: Date.today)
      end

      before do
        assign :membership, membership
        assign :participant, participant
        allow(view).to receive(:study_length_in_weeks) { NUMBER_OF_WEEKS }
        allow(view).to receive(:view_membership) { membership }
      end

      describe "participant has active membership" do
        before do
          allow(membership)
            .to receive(:end_date) { Date.tomorrow }
          render partial: "think_feel_do_engine/coach/patient_dashboards"\
          "/tables/patient_info"
        end

        it "formats start date message" do
          expect(rendered)
            .to have_text "Started on: #{membership.start_date.to_s(:user_date_with_day_of_week)}"
        end

        it "formats end date message" do
          formatted = (membership.start_date + NUMBER_OF_WEEKS.weeks)
                      .to_s(:user_date_with_day_of_week)

          expect(rendered)
            .to have_text "#{NUMBER_OF_WEEKS} weeks from the start date is: #{formatted}"
        end

        it "displays membership status" do
          expect(rendered)
            .to have_text "Status: Active Currently in week 2"
        end

        it "displays number of lessons read this week message" do
          expect(rendered)
            .to have_text "Lessons read this week: 0"
        end
      end

      describe "participant is no longer active" do
        before do
          allow(membership)
            .to receive(:end_date) { Date.yesterday }
          render partial: "think_feel_do_engine/coach/patient_dashboards"\
          "/tables/patient_info"
        end

        it "displays membership status" do
          expect(rendered)
            .to have_text "Status: Inactive Study has been Completed"
        end
      end
    end
  end
end
