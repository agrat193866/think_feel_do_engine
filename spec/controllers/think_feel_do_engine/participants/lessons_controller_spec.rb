require "spec_helper"

module ThinkFeelDoEngine
  module Participants
    urls = ThinkFeelDoEngine::Engine.routes.url_helpers

    describe Participants::LessonsController, type: :controller do
      describe "GET show" do
        context "for unauthenticated requests" do
          before { get :show, id: 1, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected participant action"
        end

        context "for authenticated requests" do
          let(:participant) { double("participant") }
          let(:arm) { double("arm", id: 123) }
          let(:lesson) { double("lesson") }

          before do
            sign_in_participant participant
          end

          context "when the lesson is found" do
            before do
              allow(ContentModules::LessonModule).to receive(:find) { lesson }
              allow(Arm).to receive(:find) { arm }
              get :show, id: 1, use_route: :think_feel_do_engine
            end

            it { expect(response.status).to eq 200 }
          end

          context "when the lesson is not found" do
            before do
              allow(ContentModules::LessonModule).to receive(:find)
                .and_raise(ActiveRecord::RecordNotFound)
              allow(participant).to receive_message_chain(
                :active_membership, :group, :arm_id
              ) { 123 }
              get :show, id: 1, use_route: :think_feel_do_engine
            end

            it do
              expect(response).to redirect_to(
                urls.navigator_context_url(context_name: "LEARN", arm_id: 123)
              )
            end
          end
        end
      end
    end
  end
end
