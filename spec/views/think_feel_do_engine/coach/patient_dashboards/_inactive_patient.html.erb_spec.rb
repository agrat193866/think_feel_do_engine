require "rails_helper"

RSpec.describe "think_feel_do_engine/coach/" \
               "patient_dashboards/_inactive_patient.html.erb",
               type: :view do
  let(:group) { instance_double(Group) }
  let(:membership) do
    instance_double(
      Membership,
      end_date: Date.today + 1.day,
      is_complete: nil,
      stepped_on: nil)
  end
  let(:patient) do
    instance_double(
      Participant,
      id: nil,
      phq_assessments: [],
      study_id: nil,
      sign_in_count: 0,
      current_sign_in_at: Time.zone.now)
  end
  let(:user) { instance_double(User) }
  let(:partial) do
    "think_feel_do_engine/coach/patient_dashboards/inactive_patient"
  end

  def permit_actions
    expect(view).to receive(:can?).with(:show, patient) { true }
  end

  context "User has permission to view participant" do
    before do
      permit_actions
    end

    context "and membership exists" do
      before do
        expect(view)
          .to receive(:coach_group_patient_dashboard_path) { "" }
        expect(view)
          .to receive_message_chain("current_user.received_messages.sent_from.unread.count")
        allow(view)
          .to receive(:view_membership) { membership }
        assign :group, group
      end

      context "and patient has logged in" do
        before do
          render partial: partial, locals: { patient: patient }
        end

        it "displays formatted sign in" do
          expect(rendered)
            .to have_text patient.current_sign_in_at.to_s(:standard)
        end
      end

      context "and patient has never logged in" do
        before do
          allow(patient).to receive(:current_sign_in_at)

          render partial: partial, locals: { patient: patient }
        end

        it "displays formatted sign in" do
          expect(rendered)
            .to have_text "Never Logged In"
        end
      end

      context "and membership was discontinued" do
        before do
          allow(membership).to receive(:is_complete) { true }

          render partial: partial, locals: { patient: patient }
        end

        it "displays discontinued date" do
          expect(rendered)
            .to have_text "Discontinued #{membership.end_date.to_s(:user_date)}"
        end
      end

      context "and membership was withdrawn" do
        before do
          allow(membership).to receive(:is_complete)

          render partial: partial, locals: { patient: patient }
        end

        it "displays withdrawn date" do
          expect(rendered)
            .to have_text "Withdrawn #{membership.end_date.to_s(:user_date)}"
        end
      end

      context "and patient is stepped" do
        before do
          allow(membership).to receive(:stepped_on) { Date.today - 15_243.years }

          render partial: partial, locals: { patient: patient }
        end

        it "displays stepped date" do
          expect(rendered)
            .to have_text membership.stepped_on.to_s(:user_date)
        end
      end
    end
  end
end
