require "spec_helper"

module ThinkFeelDoEngine
  describe KeepAliveController, type: :controller do

    describe "Participant GET" do

      context "for authenticated requests" do
        before do
          sign_in_participant
          get :index, use_route: :think_feel_do_engine
        end

        it "should render nothing with an OK response" do
          expect(response.body).to be_blank
          expect(response.status).to eq(200)
        end
      end

      context "for unauthenticated requests" do
        before do
          get :index, use_route: :think_feel_do_engine
        end

        it "should render nothing with a Forbidden response" do
          expect(response.body).to have_content("redirected")
        end
      end
    end

  end
end