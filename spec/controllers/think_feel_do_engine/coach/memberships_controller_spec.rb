require "rails_helper"

module ThinkFeelDoEngine
  module Coach
    urls = ThinkFeelDoEngine::Engine.routes.url_helpers

    RSpec.describe MembershipsController, type: :controller do
      describe "PUT update" do
        context "for unauthenticated requests" do
          before { put :update, use_route: :think_feel_do_engine }
          it_behaves_like "a rejected user action"
        end

        context "for authenticated requests" do
          context "when the user is authorized" do
            let(:group) do
              stub_group = Group.new
              allow(stub_group).to receive(:id) { 1 }

              stub_group
            end
            let(:membership) { instance_double(Membership) }
            let(:today) { Date.today }

            def stub_authorize(action, object)
              allow(controller).to receive(:authorize!).with(action, object)
                .and_return(true)
            end

            def arrange
              sign_in_user instance_double("User")
              allow(Membership).to receive(:find).with("2") { membership }
              allow(Group).to receive(:find).with("1") { group }
              stub_authorize :update, membership
            end

            context "and the membership updates successfully" do
              it "redirects to the coach patient dashboard" do
                arrange

                expect(membership).to receive(:update)
                  .with("stepped_on" => today.to_s(:db))
                  .and_return(true)

                put :update,
                    id: 2,
                    group_id: 1,
                    membership: { stepped_on: today },
                    use_route: :think_feel_do_engine

                expect(response).to redirect_to(
                  urls.coach_group_patient_dashboards_path(group)
                )
              end

              it "sets the notice" do
                arrange

                expect(membership).to receive(:update)
                  .with("stepped_on" => today.to_s(:db))
                  .and_return(true)

                put :update,
                    id: 2,
                    group_id: 1,
                    membership: { stepped_on: today },
                    use_route: :think_feel_do_engine

                expect(flash[:notice])
                  .to eq "Participant was successfully stepped."
              end
            end

            context "and the membership does not update successfully" do
              it "redirects to the coach patient dashboard" do
                arrange
                allow(membership)
                  .to receive_message_chain("errors.full_messages")
                  .and_return([])

                expect(membership).to receive(:update) { false }

                put :update,
                    id: 2,
                    group_id: 1,
                    membership: { stepped_on: today },
                    use_route: :think_feel_do_engine

                expect(response).to redirect_to(
                  urls.coach_group_patient_dashboards_path(group)
                )
              end

              it "sets the alert" do
                arrange
                allow(membership)
                  .to receive_message_chain("errors.full_messages")
                  .and_return([])

                expect(membership).to receive(:update) { false }

                put :update,
                    id: 2,
                    group_id: 1,
                    membership: { stepped_on: today },
                    use_route: :think_feel_do_engine

                expect(flash[:alert])
                  .to match(/End date cannot be set prior to tomorrow/)
              end
            end
          end
        end
      end
    end
  end
end
