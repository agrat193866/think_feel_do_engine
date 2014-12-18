require "spec_helper"

module ThinkFeelDoEngine
  module Coach
    describe PatientDashboardsController, type: :controller do
      describe "GET index" do
        let(:group) { double("group", participants: []) }

        context "for unauthenticated requests" do
          before { get :index, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          before do
            allow(Group).to receive(:find).and_return(group)
            sign_in_user double("user", participants: [], admin?: false, coach?: true)
            get :index, use_route: :think_feel_do_engine
          end

          it { expect(response).to render_template :index }
        end
      end

      describe "GET show" do
        context "for unauthenticated requests" do
          before { get :show, id: 1, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end
      end
    end
  end
end
