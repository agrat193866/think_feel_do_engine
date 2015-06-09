require "rails_helper"

module ThinkFeelDoEngine
  module Coach
    urls = ThinkFeelDoEngine::Engine.routes.url_helpers

    describe SiteMessagesController, type: :controller do
      let(:user) { double("user", admin?: true) }
      let(:group) { double("group") }

      describe "GET index" do
        context "for unauthenticated requests" do
          before { get :index, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            sign_in_user user
            allow(Group).to receive(:find).and_return(group)
            allow(user).to receive_message_chain(:participants_for_group, ids: [])
          end

          it "responds with the group's participants but scoped to the current user" do
            expect(user).to receive(:participants_for_group).with(group)

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
            sign_in_user user
            allow(Group).to receive(:find).and_return(group)
          end

          it "responds with the group's participants but scoped to the current user" do
            expect(user).to receive(:participants_for_group).with(group)

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
          before do
            sign_in_user user
            allow(Group).to receive(:find).and_return(group)
          end

          describe "with errors" do
            let(:site_message) { double("site_message", save: false) }

            before do
              allow(SiteMessage).to receive(:new) { site_message }
            end

            it "should respond with the new page if there is an error" do
              post :create, site_message: { participant_id: 1 }, use_route: :think_feel_do_engine

              expect(response).to render_template :new
            end
          end

          describe "on success" do
            let(:site_message) { double("site_message", save: true) }

            before do
              allow(SiteMessage).to receive(:new) { site_message }
              allow(SiteMessageMailer).to receive_message_chain(:general, deliver: true)
            end

            it "should respond with the show page of the message" do
              post :create, site_message: { participant_id: 1 }, use_route: :think_feel_do_engine

              expect(response).to redirect_to urls.coach_group_site_message_path(group, site_message)
            end
          end
        end
      end
    end
  end
end
