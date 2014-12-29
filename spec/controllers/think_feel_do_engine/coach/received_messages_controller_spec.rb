require "spec_helper"

module ThinkFeelDoEngine
  module Coach
    describe ReceivedMessagesController, type: :controller do
      let(:user) { double("user", admin?: true) }
      let(:group) { double("group", participants: []) }
      let(:source_message) { double("source message", sender_id: 3) }
      let(:message) do
        double("message", body: "", id: 1, message: source_message, subject: "")
      end

      describe "GET show" do
        context "for unauthenticated requests" do
          before { get :show, id: 1, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before { sign_in_user user }

          context "when the message is found" do
            before do
              allow(Group).to receive(:find).and_return(group)
              allow(user).to receive_message_chain(:received_messages, :find)
                .and_return(message)
              get :show, id: 1, use_route: :think_feel_do_engine
            end

            it "should render the show page" do
              expect(response).to render_template :show
            end
          end

          context "when the message is not found" do
            before do
              allow(user).to receive_message_chain(:received_messages, :find)
                .and_raise(ActiveRecord::RecordNotFound)
              get :show, id: 1, use_route: :think_feel_do_engine
            end

            it "should redirect to the root" do
              expect(response).to redirect_to "/"
            end
          end
        end
      end
    end
  end
end
