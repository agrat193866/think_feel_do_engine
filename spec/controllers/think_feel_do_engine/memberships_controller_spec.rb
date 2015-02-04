require "spec_helper"

module ThinkFeelDoEngine
  describe MembershipsController, type: :controller do
    describe "Membership Patch" do
      let(:user) { double("user", admin?: true) }
      let(:membership) { double("membership", id: 1, end_date: Date.tomorrow.to_date) }
      let(:membership_valid) { double("membership_valid", end_date: Date.tomorrow.to_date) }
      let(:membership_invalid) { double("membership_invalid", end_date: Date.today.to_date) }

      context "valid end date submission" do
        before do
          sign_in_user user
          allow(Membership).to receive(:find) { membership }
          allow(membership).to receive(:update) { true }
          allow(membership).to receive(:group) { double("some_group") }
          put :update,
              id: 1,
              membership: { end_date: Date.tomorrow.to_date },
              use_route: :think_feel_do_engine
        end

        it "should render a notice alert message OK response" do
          expect(flash[:notice]).to be_present
        end
      end

      context "invalid end date submission" do
        before do
          sign_in_user user
          allow(Membership).to receive(:find) { membership }
          allow(membership).to receive(:update) { false }
          allow(membership).to receive(:group) { double("some_group") }
          put :update,
              id: 1,
              membership: { end_date: Date.today.to_date },
              use_route: :think_feel_do_engine
        end

        it "should render nothing with an OK response" do
          expect(flash[:alert]).to be_present
        end
      end
    end
  end
end


