require "rails_helper"

PARTIAL = "think_feel_do_engine/coach/patient_dashboards/" \
          "active_patient"

RSpec.describe PARTIAL, type: :view do
  let(:membership) do
    # use a real AR instance because of form helpers
    stub_membership = Membership.new
    allow(stub_membership).to receive_messages(
      end_date: Date.new,
      day_in_study: 0,
      stepped_on: nil,
      new_record?: false,
      id: 1
    )

    stub_membership
  end
  let(:stepping_suggestion) do
    instance_double(PhqStepping,
                    urgency: nil,
                    suggestion: nil,
                    detailed_suggestion: nil,
                    assessments: [],
                    results: [],
                    week: nil)
  end
  let(:patient) do
    instance_double(Participant,
                    id: nil,
                    phq_assessments: [],
                    study_id: nil,
                    sign_in_count: nil,
                    current_sign_in_at: nil,
                    most_recent_membership: membership,
                    stepping_suggestion: stepping_suggestion)
  end
  let(:group) do
    # use a real AR instance because of form helpers
    stub_group = Group.new
    allow(stub_group).to receive(:id) { 3 }

    stub_group
  end
  let(:user) do
    stub_user = instance_double(User)
    allow(stub_user)
      .to receive_message_chain("received_messages.sent_from.unread")
      .and_return([])

    stub_user
  end

  context "when the User can show the patient" do
    def permit_actions
      allow(view).to receive(:can?).with(:show, patient) { true }
      allow(view).to receive(:can?).with(:update, membership) { true }
    end

    context "and phq features are on" do
      context "and the membership exists" do
        def arrange
          allow(view).to receive(:view_membership) { membership }
          allow(view).to receive(:current_user) { user }
          assign :group, group
          stub_template "think_feel_do_engine/coach/patient_dashboards/_details.html.erb" => ""
        end

        it "renders the Discontinue button" do
          arrange
          permit_actions
          allow(view).to receive(:phq_features?) { true }

          render partial: PARTIAL, locals: { patient: patient }

          expect(rendered).to have_selector("form[action='/memberships/1/discontinue'] " \
                                            ".btn[value='Discontinue']")
        end

        context "and the patient has not been stepped" do
          it "does not render 'Stepped'" do
            arrange
            permit_actions
            allow(view).to receive(:phq_features?) { true }
            allow(membership).to receive(:stepped_on) { nil }

            render partial: PARTIAL, locals: { patient: patient }

            expect(rendered).not_to have_text("Stepped")
          end

          it "renders the Step control" do
            arrange
            permit_actions
            allow(view).to receive(:phq_features?) { true }
            allow(membership).to receive(:stepped_on) { nil }

            render partial: PARTIAL, locals: { patient: patient }

            expect(rendered).to have_selector("form[action='/coach/groups/3/memberships/1'] " \
                                              ".btn[value='Step']")
            expect(rendered)
              .to have_selector("form[action='/coach/groups/3/memberships/1'] " \
                                "input[name='membership[stepped_on]'][value='#{ Date.today }']")
          end
        end

        context "and the patient has been stepped" do
          it "renders 'Stepped'" do
            arrange
            permit_actions
            allow(view).to receive(:phq_features?) { true }
            allow(membership).to receive(:stepped_on) { Date.today }

            render partial: PARTIAL, locals: { patient: patient }

            expect(rendered).to have_text("Stepped")
          end

          it "does not render the Step button" do
            arrange
            permit_actions
            allow(view).to receive(:phq_features?) { true }
            allow(membership).to receive(:stepped_on) { Date.today }

            render partial: PARTIAL, locals: { patient: patient }

            expect(rendered).not_to have_selector("form[action='/coach/groups/3/memberships/1'] " \
                                                  ".btn[value='Step']")
          end
        end
      end
    end
  end
end
