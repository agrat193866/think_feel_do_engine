require "rails_helper"

module ThinkFeelDoEngine
  RSpec.describe ApplicationHelper, type: :helper do
    let(:configuration) { Rails.application.config }

    describe "#host_email_link" do
      before do
        configuration.action_mailer.default_url_options[:host] = "sloth@ex.co"
      end

      it "returns the host application's url" do
        expect(helper.host_email_link).to eq "sloth@ex.co"
      end
    end

    describe "#phq_features?" do
      context "PHQ features exist" do
        before do
          configuration.include_phq_features = true
        end

        it "returns true" do
          expect(helper.phq_features?).to eq true
        end
      end

      context "PHQ features do not exist" do
        before do
          configuration.include_phq_features = false
        end

        it "returns false" do
          expect(helper.phq_features?).to eq false
        end
      end
    end

    describe "#social_features?" do
      context "Social features exist" do
        before do
          configuration.include_social_features = true
        end

        it "returns true" do
          expect(helper.social_features?).to eq true
        end
      end

      context "Social features do not exist" do
        before do
          configuration.include_social_features = false
        end

        it "returns false" do
          expect(helper.social_features?).to eq false
        end
      end
    end
  end
end
