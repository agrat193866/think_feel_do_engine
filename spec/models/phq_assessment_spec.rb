require "rails_helper"

RSpec.describe PhqAssessment, type: :model do
  fixtures :all

  let(:valid_attributes) do
    {
      participant: Participant.first,
      release_date: Date.current,
      q1: 0,
      q2: 1,
      q3: 2,
      q8: 3
    }
  end

  describe "validations" do
    describe "when invalid" do
      it "returns error when 'participant' is not defined" do
        valid_attributes.delete(:participant)

        expect(
          PhqAssessment.new(valid_attributes)
          .tap(&:valid?).errors.full_messages)
          .to include("Participant can't be blank")
      end

      it "returns error when 'release_date' is not defined" do
        valid_attributes.delete(:release_date)

        expect(
          PhqAssessment.new(valid_attributes)
          .tap(&:valid?).errors.full_messages)
          .to include("Release date can't be blank")
      end

      it "returns `false` when an assessment has been released on the same date twice" do
        PhqAssessment.create(valid_attributes)

        expect(
          PhqAssessment.new(valid_attributes)
          .tap(&:valid?).errors.full_messages)
          .to include("Release date has already been taken")
      end
    end

    context "when the attributes are valid" do
      it "is valid" do
        expect(PhqAssessment.new(valid_attributes))
          .to be_valid
      end
    end

    context "when a response is below the minimum allowed" do
      it "is not valid" do
        expect(PhqAssessment.new(valid_attributes.merge(q4: -1)))
          .not_to be_valid
      end
    end

    context "when a response is above the maximum allowed" do
      it "is not valid" do
        expect(PhqAssessment.new(valid_attributes.merge(q4: 4)))
          .not_to be_valid
      end
    end
  end

  describe "scopes" do
    let(:participant) { participants(:traveling_participant1) }

    describe ".most_recent" do
      it "returns the most recent phq" do
        expect(participant.phq_assessments.most_recent)
          .to eq phq_assessments(:phq_released_last_week)
      end

      describe "when an assessment is updated" do
        it "returns the phq based on release date" do
          phq_assessments(:phq_released_two_weeks_ago).update!(q1: 1)

          expect(participant.phq_assessments.most_recent)
            .to eq phq_assessments(:phq_released_last_week)
        end
      end
    end
  end

  describe "#completed?" do
    it "returns `true` if all questions have been answered" do
      phq = PhqAssessment.new(valid_attributes.merge(q4: 0, q5: 1, q6: 2,
                                                     q7: 3, q9: 1))

      expect(phq.completed?).to eq true
    end

    it "returns `false` if not all questions have been answered" do
      phq = PhqAssessment.new(valid_attributes)

      expect(phq.completed?).to eq false
    end
  end

  describe "#number_answered" do
    it "returns the count of questions that are not nil" do
      phq = PhqAssessment.new(valid_attributes.merge(q7: nil))

      expect(phq.number_answered).to eq 4
    end

    it "returns the count of questions that are not nil" do
      phq = PhqAssessment.new(valid_attributes)

      expect(phq.number_answered).to eq 4
    end
  end

  describe "#score" do
    it "returns the cumulative non-nil total" do
      phq = PhqAssessment.new(valid_attributes)

      expect(phq.score).to eq 6
    end
  end

  describe "#suicidal?" do
    it "returns true when the last question is too high" do
      phq = PhqAssessment.new(valid_attributes.merge(q9: 3))

      expect(phq.suicidal?).to eq true
    end

    it "returns false when the last question is not too high" do
      phq = PhqAssessment.new(valid_attributes.merge(q9: 2))

      expect(phq.suicidal?).to eq false
    end
  end
end
