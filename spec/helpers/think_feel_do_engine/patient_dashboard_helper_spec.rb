require "rails_helper"

module ThinkFeelDoEngine
  module Coach
    RSpec.describe PatientDashboardHelper, type: :helper do
      let(:activities) { double("activities") }
      let(:participant) { double("participant", activities: activities) }

      describe "#breadcrumbs" do
        it "returns nil for the wrong controller" do
          allow(helper).to receive(:controller_name) { "baz" }

          expect(helper.breadcrumbs).to be_nil
        end

        it "returns breadcrumbs for viz controllers" do
          allow(helper).to receive(:controller_name)
            .and_return("participant_activities_visualizations")
          allow(helper).to receive(:coach_group_patient_dashboard_path)
            .and_return("")
          @participant = double("participant", active_group: double("group"))

          expect(helper).to receive(:content_for)
            .with(:breadcrumbs, /Patient Dashboard/)

          helper.breadcrumbs
        end
      end

      describe "#activities_planned_today" do
        it "should return a sum of all planned activities for today" do
          expect(participant).to receive(:activities).exactly(3).times { activities }
          expect(activities)
            .to receive_message_chain(:planned, :for_day, :count) { 1 }
          expect(activities)
            .to receive_message_chain(:reviewed_and_complete, :for_day, :count) { 1 }
          expect(activities)
            .to receive_message_chain(:reviewed_and_incomplete, :for_day, :count) { 1 }
          expect(activities_planned_today(participant)).to eq(3)
        end
      end

      describe "#activities_planned_7_day" do
        it "should return a sum of planned activities for the last 7 days" do
          expect(participant).to receive(:activities).exactly(3).times { activities }
          expect(activities)
            .to receive_message_chain(:planned, :last_seven_days, :count) { 1 }
          expect(activities)
            .to receive_message_chain(:reviewed_and_complete, :last_seven_days, :count) { 1 }
          expect(activities)
            .to receive_message_chain(:reviewed_and_incomplete, :last_seven_days, :count) { 1 }
          expect(activities_planned_7_day(participant)).to eq(3)
        end
      end

      describe "#activities_planned_total" do
        it "should return a sum of all planned activities for all time" do
          expect(participant).to receive(:activities).exactly(3).times { activities }
          expect(activities)
            .to receive_message_chain(:planned, :count) { 1 }
          expect(activities)
            .to receive_message_chain(:reviewed_and_complete, :count) { 1 }
          expect(activities)
            .to receive_message_chain(:reviewed_and_incomplete, :count) { 1 }
          expect(activities_planned_total(participant)).to eq(3)
        end
      end
    end
  end
end
