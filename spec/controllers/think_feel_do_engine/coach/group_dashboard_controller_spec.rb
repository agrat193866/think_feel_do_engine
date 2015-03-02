require "rails_helper"

module ThinkFeelDoEngine
  module Coach
    describe GroupDashboardController, type: :controller do
      describe "GET index" do
        let(:group) { double("group", participants: Participant.all) }

        context "for unauthenticated requests" do
          before { get :index, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            allow(Group).to receive(:find).and_return(group)
            allow(group).to receive(:id)
            sign_in_user double("user",
                                participants: Participant.all,
                                admin?: true,
                                coach?: true,
                                content_author?: false,
                                researcher?: false)
            get :index, use_route: :think_feel_do_engine
          end

          it "should respond with the index page" do
            expect(response).to render_template :index
          end
        end
      end
    end
  end
end
