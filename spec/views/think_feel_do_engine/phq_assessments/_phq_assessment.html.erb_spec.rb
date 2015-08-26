require "rails_helper"

RSpec.describe "think_feel_do_engine/phq_assessments/_phq_assessment.html.erb",
               type: :view do
  describe "phq9 data table" do
    def assessment(options = {})
      instance_double(
        PhqAssessment, {
          suicidal?: true,
          created_at: Date.yesterday,
          release_date: Date.today,
          score: 1,
          completed?: true
        }.merge(options)
      )
    end

    def expect_assessment_to_receive_questions(assessment)
      [:q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :q9].each do |q|
        expect(assessment).to receive(q)
      end
    end

    before do
      expect(view).to receive(:phq_warning)
    end

    describe "when suicidal" do
      let(:phq_assessment) { assessment }

      it "displays warning class" do
        expect_assessment_to_receive_questions(phq_assessment)

        render partial: "think_feel_do_engine/phq_assessments/phq_assessment",
               collection: [phq_assessment]

        expect(rendered).to have_css "tr.danger"
      end
    end

    describe "when not suicidal" do
      let(:phq_assessment) { assessment(suicidal?: false) }

      it "doesn't displays warning class" do
        expect_assessment_to_receive_questions(phq_assessment)

        render partial: "think_feel_do_engine/phq_assessments/phq_assessment",
               collection: [phq_assessment]

        expect(rendered).to_not have_css "tr.danger"
      end

      it "displays formatted timestamps" do
        expect_assessment_to_receive_questions(phq_assessment)

        render partial: "think_feel_do_engine/phq_assessments/phq_assessment",
               collection: [phq_assessment]

        expect(rendered).to have_text "Created #{Date.yesterday.to_s(:user_date)}"
        expect(rendered).to have_text "Released #{Date.today.to_s(:user_date)}"
      end
    end

    describe "when pqh9 is completed" do
      let(:phq_assessment) { assessment }

      it "displays the phq9 data" do
        expect_assessment_to_receive_questions(phq_assessment)

        render partial: "think_feel_do_engine/phq_assessments/phq_assessment",
               collection: [phq_assessment]

        expect(rendered).to_not have_text "*"
      end
    end

    describe "when pqh9 is not completed" do
      let(:phq_assessment) { assessment(completed?: false) }

      it "displays the phq9 data" do
        expect_assessment_to_receive_questions(phq_assessment)

        render partial: "think_feel_do_engine/phq_assessments/phq_assessment",
               collection: [phq_assessment]

        expect(rendered).to have_text "*"
      end
    end
  end
end
