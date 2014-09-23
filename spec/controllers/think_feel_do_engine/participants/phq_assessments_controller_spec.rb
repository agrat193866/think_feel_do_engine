require "spec_helper"

module ThinkFeelDoEngine
  module Participants
    urls = ThinkFeelDoEngine::Engine.routes.url_helpers

    describe PhqAssessmentsController, type: :controller do
      shared_context "missing token" do
        before { allow(ParticipantToken).to receive(:find_by_token) { nil } }
      end

      shared_context "valid token" do
        let(:token) do
          double("participant token", participant_id: 7, release_date: Date.new)
        end
        let(:phq9) { double("PHQ9") }
        let(:participant) { double("participant", build_phq_assessment: phq9) }

        before do
          allow(ParticipantToken).to receive(:find_by_token).with("T") { token }
          allow(Participant).to receive(:find) { participant }
        end
      end

      shared_examples "token authorizer" do
        it("should redirect to root") { expect(response).to redirect_to(urls.root_url) }
      end

      describe "GET new" do
        describe "when the token is not found" do
          include_context "missing token"
          before { get :new, use_route: :think_feel_do_engine }
          it_behaves_like "token authorizer"
        end

        describe "when the token is found" do
          include_context "valid token"

          it "should render the 'new' view" do
            get :new, phq_assessment: { token: "T" }, use_route: :think_feel_do_engine

            expect(response).to render_template(:new)
          end
        end
      end

      describe "POST create" do
        describe "when the token is not found" do
          include_context "missing token"
          before { post :create, use_route: :think_feel_do_engine }
          it_behaves_like "token authorizer"
        end

        describe "when the token is found" do
          include_context "valid token"

          describe "and the assessment saves" do
            before { allow(phq9).to receive(:save) { true } }

            it "should render success" do
              post :create, phq_assessment: { q1: 1, q2: 2, q3: 3, q4: 4, q5: 5,
                                              q6: 6, q7: 7, q8: 8, q9: 9,
                                              token: "T" }, use_route: :think_feel_do_engine

              expect(response).to render_template(:success)
            end
          end

          describe "and the assessment does not save" do
            before do
              allow(phq9).to receive(:save) { false }
              allow(phq9).to receive_message_chain(:errors, :full_messages) { [] }
            end

            it "should render new" do
              post :create, phq_assessment: { q1: 1, q2: 2, q3: 3, q4: 4, q5: 5,
                                              q6: 6, q7: 7, q8: 8, q9: 9,
                                              token: "T" }, use_route: :think_feel_do_engine

              expect(response).to render_template(:new)
            end
          end
        end
      end
    end
  end
end
