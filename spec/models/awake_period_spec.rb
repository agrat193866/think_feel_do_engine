require "spec_helper"

describe AwakePeriod do
  fixtures :participants, :awake_periods

  describe "validations" do
    let(:participant1_overlap_period) do
      period = awake_periods(:participant1_period1)

      participants(:participant1).awake_periods.build(
        start_time: period.start_time,
        end_time: period.end_time
      )
    end

    let(:participant1_nonoverlap_period) do
      period = awake_periods(:participant2_period1)

      participants(:participant1).awake_periods.build(
        start_time: period.start_time,
        end_time: period.end_time
      )
    end

    it "prevents overlapping periods for a participant" do
      expect(participant1_overlap_period).not_to be_valid
    end

    it "allows overlapping periods for different participants" do
      expect(participant1_nonoverlap_period).to be_valid
    end
  end
end
