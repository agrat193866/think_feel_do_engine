require "rails_helper"

module ThinkFeelDoEngine
  module Coach
    RSpec.describe PatientDashboardHelper, type: :helper do
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
    end
  end
end
