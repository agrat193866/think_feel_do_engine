require "rails_helper"

feature "assessments", type: :feature do
  describe "when a participant accesses a valid link" do
    fixtures :participants

    context "for a phq token" do
      let(:token) do
        participants(:participant1).participant_tokens
          .create!(token_type: "phq9", release_date: Date.today)
          .token
      end

      it "can be completed" do
        visit "/participants/assessments/new?assessment[token]=#{ token }"

        expect(page).to have_text("PHQ-9")

        expect do
          click_on("submit")
        end.to change { PhqAssessment.count }.by(1)

        expect(page).to have_text("Thank you")
      end
    end

    context "for two tokens" do
      let(:phq_token) do
        participants(:participant1).participant_tokens
          .create!(token_type: "phq9", release_date: Date.today)
          .token
      end

      before do
        participants(:participant1).participant_tokens
          .create!(token_type: "wai", release_date: Date.today)
      end

      it "both can be completed" do
        visit "/participants/assessments/new?assessment[token]=#{ phq_token }"

        expect(page).to have_text("PHQ-9")

        expect do
          click_on("submit")
        end.to change { PhqAssessment.count }.by(1)

        expect(page).to have_text("Working Alliance Inventory")

        expect do
          click_on("submit")
        end.to change { WaiAssessment.count }.by(1)

        expect(page).to have_text("Thank you")
      end
    end
  end
end
