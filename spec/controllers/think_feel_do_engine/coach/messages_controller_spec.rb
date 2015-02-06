require "rails_helper"

module ThinkFeelDoEngine
  module Coach
    urls = ThinkFeelDoEngine::Engine.routes.url_helpers

    describe MessagesController, type: :controller do
      let(:group) { double("group", participant_ids: []) }
      let(:user) do
        double("user",
               admin?: false,
               coach?: true,
               content_author?: false,
               researcher?: false)
      end

      before do
        allow(user).to receive_message_chain(:participants, :where) { [] }
      end

      describe "GET index" do
        context "for unauthenticated requests" do
          before { get :index, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            allow(user).to receive(:received_messages) { DeliveredMessage }
            allow(user).to receive(:sent_messages) { Message }
            sign_in_user user
          end

          it "should render the coach messages index" do
            allow(Group).to receive(:find).and_return(group)

            get :index, use_route: :think_feel_do_engine
            expect(response).to render_template :index
          end
        end
      end

      describe "GET new" do
        context "for unauthenticated requests" do
          before { get :new, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            allow(user).to receive(:build_sent_message) { nil }
            sign_in_user user
          end

          it "should render the new coach message form" do
            allow(Group).to receive(:find) { group }

            get :new, use_route: :think_feel_do_engine
            expect(response).to render_template :new
          end
        end
      end

      describe "POST create" do
        context "for unauthenticated requests" do
          before { post :create, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          let(:message) { double("message", save: true) }
          let(:user) do
            double("user",
                   build_sent_message: message,
                   admin?: false,
                   coach?: true,
                   content_author?: false,
                   researcher?: false)
          end

          before { sign_in_user user }

          context "when the message saves" do
            before do
              allow(Group).to receive(:find) { group }
              post :create, message: {
                recipient_id: 1, recipient_type: "foo", subject: "bar", body: "asdf"
              }, use_route: :think_feel_do_engine
            end

            it { expect(response).to redirect_to urls.coach_group_messages_url(group) }
          end

          context "when the message does not save" do
            let(:errors) { double("errors", full_messages: []) }
            let(:message) { double("message", save: false, errors: errors) }
            before do
              request.env["HTTP_REFERER"] = urls.new_coach_group_message_url(group)
              allow(Group).to receive(:find) { group }
              post :create, message: {
                recipient_id: 1, recipient_type: "foo", subject: "bar", body: "asdf"
              }, use_route: :think_feel_do_engine
            end

            it { expect(response).to redirect_to :back }
          end
        end
      end
    end
  end
end
