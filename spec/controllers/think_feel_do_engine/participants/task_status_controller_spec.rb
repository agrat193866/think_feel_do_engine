require "spec_helper"

module ThinkFeelDoEngine
  module Participants
    describe TaskStatusController, type: :controller do
      describe "PUT update" do
        context "for unauthenticated requests" do
          before { put :update, id: 1, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected participant action"
        end

        context "for authenticated requests" do
          let(:task_status) { double("task status") }
          let(:participant) { double("participant") }

          before do
            allow(participant).to receive_message_chain(:active_membership,
                                                        :task_statuses,
                                                        :find) { task_status }
            sign_in_participant participant
            allow(task_status).to receive_message_chain(:engagements, :build)
              .and_return(true)
          end

          context "that complete successfully" do
            before do
              allow(task_status).to receive(:mark_complete) { true }
              put :update, id: 1, use_route: :think_feel_do_engine
            end

            it { expect(response.status).to eq 200 }
          end

          context "that fail to complete" do
            before do
              allow(task_status).to receive(:mark_complete) { false }
              put :update, id: 1, use_route: :think_feel_do_engine
            end

            it { expect(response.status).to eq 400 }
          end
        end
      end
    end
  end
end
