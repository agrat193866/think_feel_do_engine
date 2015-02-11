require "rails_helper"

module ThinkFeelDoEngine
  describe KeepAliveController, type: :controller do
    describe "GET" do
      fixtures :all

      context "for authenticated participants" do
        before do
          sign_in_participant
          get :index, use_route: :think_feel_do_engine
        end

        it "should render nothing with an OK response" do
          expect(response.body).to be_blank
          expect(response.status).to eq(200)
        end
      end

      context "for unauthenticated participants" do
        before do
          get :index, use_route: :think_feel_do_engine
        end

        it "should render nothing with a Forbidden response" do
          expect(response.body).to be_blank
          expect(response.status).to eq(401)
        end
      end

      context "for authenticated users" do
        before do
          sign_in_user users(:clinician1)
          get :index, use_route: :think_feel_do_engine
        end

        it "should render nothing with an OK response" do
          expect(response.body).to be_blank
          expect(response.status).to eq(200)
        end
      end

      context "for unauthenticated users" do
        before do
          get :index, use_route: :think_feel_do_engine
        end

        it "should render nothing with a Forbidden response" do
          expect(response.body).to be_blank
          expect(response.status).to eq(401)
        end
      end
    end
  end
end