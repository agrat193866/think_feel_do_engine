require "rails_helper"

module ThinkFeelDoEngine
  describe MembershipsController, type: :controller do
    let(:user) { instance_double("User", admin?: true) }
    let(:membership) do
      instance_double("Membership", group: instance_double("Group"))
    end

    before do
      allow(Membership).to receive(:find) { membership }
      sign_in_user user
    end

    describe "PUT update" do
      context "when the membership is updated successfully" do
        it "should render a notice alert message OK response" do
          allow(membership).to receive(:update) { true }

          put :update,
              id: 1,
              membership: { end_date: Date.tomorrow },
              use_route: :think_feel_do_engine

          expect(flash[:notice]).to be_present
        end
      end

      context "invalid end date submission" do
        it "should render nothing with an OK response" do
          allow(membership).to receive(:update) { false }

          put :update,
              id: 1,
              membership: { end_date: Date.current },
              use_route: :think_feel_do_engine

          expect(flash[:alert]).to be_present
        end
      end
    end

    describe "GET withdraw" do
      context "when the membership is withdrawn successfully" do
        it "sets a notice" do
          allow(membership).to receive(:withdraw) { true }

          get :withdraw, id: 1, use_route: :think_feel_do_engine

          expect(flash[:notice]).to be_present
        end
      end

      context "when the membership is not withdrawn successfully" do
        it "sets an alert" do
          allow(membership).to receive(:withdraw) { false }
          allow(membership)
            .to receive_message_chain("errors.full_messages") { ["baz"] }

          get :withdraw, id: 1, use_route: :think_feel_do_engine

          expect(flash[:alert]).to be_present
        end
      end
    end

    describe "GET discontinue" do
      context "when the membership is discontinued successfully" do
        it "sets a notice" do
          allow(membership).to receive(:discontinue) { true }

          get :discontinue, id: 1, use_route: :think_feel_do_engine

          expect(flash[:notice]).to be_present
        end
      end

      context "when the membership is not discontinued successfully" do
        it "sets an alert" do
          allow(membership).to receive(:discontinue) { false }
          allow(membership)
            .to receive_message_chain("errors.full_messages") { ["baz"] }

          get :discontinue, id: 1, use_route: :think_feel_do_engine

          expect(flash[:alert]).to be_present
        end
      end
    end
  end
end


