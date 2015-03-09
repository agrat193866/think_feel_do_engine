require "rails_helper"

module ThinkFeelDoEngine
  module Participants
    RSpec.describe ActivitiesController, type: :controller do
      describe "PUT update" do
        let(:activity) { double("activity") }
        let(:participant) { double("participant") }

        context "activity updates with update_as_reviewed" do
          before do
            sign_in_participant participant
            allow(participant).to receive(:activities) { Activity }
            allow(Activity).to receive(:find) { activity }
            allow(activity).to receive(:update_as_reviewed) { true }
            put :update,
                id: 1,
                activity: {
                  actual_accomplishment_intensity: 1,
                  actual_pleasure_intensity: 4
                },
                use_route: :think_feel_do_engine,
                format: :js
          end

          it "responds with js and visits the current page with success notice" do
            expect(flash[:notice]).to be_present
            expect(response.body).to eq "Turbolinks.visit(window.location);"
          end
        end

        context "activity does not update with update_as_reviewed" do
          before do
            sign_in_participant participant
            allow(participant).to receive(:activities) { Activity }
            allow(Activity).to receive(:find) { activity }
            allow(activity).to receive(:update_as_reviewed) { false }
            allow(activity)
              .to receive_message_chain(:errors, :full_messages) { ["Errors"] }
            put :update,
                id: 1,
                activity: {
                  actual_accomplishment_intensity: 1,
                  actual_pleasure_intensity: 4
                },
                use_route: :think_feel_do_engine,
                format: :js
          end

          it "responds with js and visits the current page with a error alert" do
            expect(flash[:alert]).to be_present
            expect(response.body).to eq "Turbolinks.visit(window.location);"
          end
        end
      end
    end
  end
end
