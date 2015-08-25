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
  let(:today) { Date.today }

  context "when the User can show the patient" do
    def arrange_stubs
      allow(view).to receive(:view_membership) { membership }
      allow(view).to receive(:current_user) { user }
      assign :group, group
      stub_template "think_feel_do_engine/coach/patient_dashboards/_details.html.erb" => ""
    end

    def permit_actions
      allow(view).to receive(:can?).with(:show, patient) { true }
      allow(view).to receive(:can?).with(:update, membership) { true }
    end

    def enable_phq_features(are_enabled = true)
      allow(view).to receive(:phq_features?) { are_enabled }
    end

    # phq features can be on or off for this context
    context "and the membership exists" do
      it "renders the Terminate Access button" do
        arrange_stubs
        permit_actions
        enable_phq_features false

        render partial: PARTIAL, locals: { patient: patient }

        expect(rendered)
          .to have_selector("form[action='/memberships/1/withdraw'][method='get'] " \
                            ".btn[value='Terminate Access']")
      end
    end

    context "and the patient has signed in" do
      it "renders the timestamp" do
        arrange_stubs
        permit_actions
        enable_phq_features false
        timestamp = DateTime.now
        allow(patient).to receive(:current_sign_in_at) { timestamp }

        render partial: PARTIAL, locals: { patient: patient }

        expect(rendered)
          .to have_text timestamp.to_s(:standard)
      end
    end

    context "and the patient has not signed in" do
      it "renders a message" do
        arrange_stubs
        permit_actions
        enable_phq_features false
        allow(patient).to receive(:current_sign_in_at)

        render partial: PARTIAL, locals: { patient: patient }

        expect(rendered).to have_text("Never Logged In")
      end
    end

    context "and phq features are on" do
      context "and the membership exists" do
        it "renders the Discontinue button" do
          arrange_stubs
          permit_actions
          enable_phq_features

          render partial: PARTIAL, locals: { patient: patient }

          expect(rendered)
            .to have_selector("form[action='/memberships/1/discontinue'][method='get'] " \
                              ".btn[value='Discontinue']")
        end

        context "and the patient has not been stepped" do
          it "does not render 'Stepped'" do
            arrange_stubs
            permit_actions
            enable_phq_features
            allow(membership).to receive(:stepped_on) { nil }

            render partial: PARTIAL, locals: { patient: patient }

            expect(rendered).not_to have_text("Stepped")
          end

          it "renders the Step control" do
            arrange_stubs
            permit_actions
            enable_phq_features
            allow(membership).to receive(:stepped_on) { nil }

            render partial: PARTIAL, locals: { patient: patient }

            expect(rendered)
              .to have_selector("form[action='/coach/groups/3/memberships/1'] " \
                                ".btn[value='Step']")
            expect(rendered)
              .to have_selector("form[action='/coach/groups/3/memberships/1'] " \
                                "input[name='_method'][value='put']",
                                visible: false)
            expect(rendered)
              .to have_selector("form[action='/coach/groups/3/memberships/1'] " \
                                "input[name='membership[stepped_on]'][value='#{ today }']")
          end
        end

        context "and the patient has been stepped" do
          it "renders 'Stepped'" do
            arrange_stubs
            permit_actions
            enable_phq_features
            allow(membership).to receive(:stepped_on) { today }

            render partial: PARTIAL, locals: { patient: patient }

            expect(rendered).to have_text("Stepped")
          end

          it "does not render the Step button" do
            arrange_stubs
            permit_actions
            enable_phq_features
            allow(membership).to receive(:stepped_on) { today }

            render partial: PARTIAL, locals: { patient: patient }

            expect(rendered).not_to have_selector(".btn[value='Step']")
          end
        end

        context "and the patient has at least one phq result" do
          context "and the last phq result rates as suicidal" do
            it "renders a warning message" do
              arrange_stubs
              permit_actions
              enable_phq_features
              assessment = instance_double(PhqAssessment,
                                           suicidal?: true,
                                           score: 15,
                                           completed?: false,
                                           release_date: today)
              allow(patient).to receive(:phq_assessments) { [assessment] }

              render partial: PARTIAL, locals: { patient: patient }

              release_date = today.to_s(:standard)
              expect(rendered).to have_text("PHQ-9 WARNING 15 * on #{ release_date }")
            end
          end

          context "and the last phq was not completed" do
            it "renders a '*'" do
              arrange_stubs
              permit_actions
              enable_phq_features
              assessment = instance_double(PhqAssessment,
                                           suicidal?: false,
                                           score: 5,
                                           completed?: false,
                                           release_date: today)
              allow(patient).to receive(:phq_assessments) { [assessment] }

              render partial: PARTIAL, locals: { patient: patient }

              release_date = today.to_s(:standard)
              expect(rendered).to have_text("5 * on #{ release_date }")
            end
          end

          context "and the last phq was completed" do
            it "does not render a '*'" do
              arrange_stubs
              permit_actions
              enable_phq_features
              assessment = instance_double(PhqAssessment,
                                           suicidal?: false,
                                           score: 8,
                                           completed?: true,
                                           release_date: today)
              allow(patient).to receive(:phq_assessments) { [assessment] }

              render partial: PARTIAL, locals: { patient: patient }

              release_date = today.to_s(:standard)
              expect(rendered).to have_text("8 on #{ release_date }")
            end
          end
        end

        context "and the patient has no phq results" do
          it "renders a message indicating that" do
            arrange_stubs
            permit_actions
            enable_phq_features
            allow(patient).to receive(:phq_assessments) { [] }

            render partial: PARTIAL, locals: { patient: patient }

            expect(rendered).to have_text("No Completed Assessments")
          end
        end
      end
    end
  end
end
