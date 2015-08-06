require "rails_helper"

PARTIAL = "think_feel_do_engine/coach/patient_dashboards/" \
          "active_patient"

RSpec.describe PARTIAL, type: :view do
  context "when the User can show the patient" do
    context "and phq features are on" do
      it "renders the Discontinue button" do
        # use a real AR instance because of form helpers
        membership = Membership.new
        allow(membership).to receive_messages(
          end_date: Date.new,
          day_in_study: 0,
          stepped_on: nil,
          new_record?: false,
          id: 1
        )
        suggestion = instance_double(PhqStepping,
                                     urgency: nil,
                                     suggestion: nil,
                                     detailed_suggestion: nil,
                                     assessments: [],
                                     results: [],
                                     week: nil)
        patient = instance_double(Participant,
                                  id: nil,
                                  phq_assessments: [],
                                  study_id: nil,
                                  sign_in_count: nil,
                                  current_sign_in_at: nil,
                                  most_recent_membership: membership,
                                  stepping_suggestion: suggestion)
        group = instance_double(Group, id: nil)
        user = instance_double(User)
        allow(user)
          .to receive_message_chain("received_messages.sent_from.unread")
          .and_return([])
        allow(view).to receive(:view_membership) { membership }
        allow(view).to receive(:current_user) { user }
        assign :group, group
        stub_template "think_feel_do_engine/coach/patient_dashboards/_details.html.erb" => ""

        allow(view).to receive(:can?).with(:show, patient) { true }
        allow(view).to receive(:can?).with(:update, membership) { true }
        allow(view).to receive(:phq_features?) { true }

        render partial: PARTIAL,
               locals: { patient: patient }

        expect(rendered).to have_selector("form[action='/memberships/1/discontinue'] " \
                                          ".btn[value='Discontinue']")
      end
    end
  end

  context "when the User cannot show the patient" do
  end
end
