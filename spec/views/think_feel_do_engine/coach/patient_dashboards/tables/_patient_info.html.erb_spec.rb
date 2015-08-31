require "rails_helper"

module SocialNetworking
  RSpec.describe "think_feel_do_engine/coach/patient_dashboards"\
                 "/tables/_patient_info.html.erb",
                 type: :view do
    describe "profile info summary" do
      NUMBER_OF_WEEKS = 1
      let(:participant) { instance_double(Participant) }
      let(:membership) do
        instance_double(
          Membership,
          day_in_study: 1,
          end_date: Date.tomorrow,
          lessons_read_for_week: [],
          start_date: Date.today)
      end

      before do
        assign :membership, membership
        assign :participant, participant
        allow(view).to receive(:study_length_in_weeks) { NUMBER_OF_WEEKS }
        allow(view).to receive(:view_membership) { membership }
        render partial: "think_feel_do_engine/coach/patient_dashboards"\
               "/tables/patient_info"
      end

      it "formats start date" do
        expect(rendered)
          .to have_text membership.start_date.to_s(:user_date)
      end

      it "formats end date" do
        expect(rendered)
          .to have_text((membership.start_date + NUMBER_OF_WEEKS.weeks).to_s(:user_date))
      end
    end
  end
end
