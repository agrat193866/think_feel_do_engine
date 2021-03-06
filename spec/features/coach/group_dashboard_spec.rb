require "rails_helper"

feature "group dashboard", type: :feature do
  fixtures :all

  describe "Logged in as a clinician" do
    let(:clinician) { users(:clinician1) }
    let(:group1) { groups(:group1) }

    context "Coach views table with many patients" do
      before do
        allow(Rails.application.config).to receive(:study_length_in_weeks) { 8 }
        allow(Rails.application.config)
          .to receive(:include_social_features) { true }
        sign_in_user clinician
        visit "/coach/groups/#{group1.id}/group_dashboard"
      end

      it "should display likes container" do
        expect(page.has_css?("#likes-container")).to be_truthy
      end
    end
  end
end
