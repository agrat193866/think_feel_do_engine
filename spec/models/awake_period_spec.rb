require "rails_helper"

describe AwakePeriod do
  fixtures :participants, :awake_periods, :activity_types

  describe "validations" do
    let(:period1) { awake_periods(:participant1_period1) }
    let(:period2) { awake_periods(:participant2_period1) }
    let(:participant) { participants(:participant1) }
    let(:participant3) { participants(:participant3) }

    let(:participant1_overlap_period) do
      participant.awake_periods.build(
        start_time: period1.start_time,
        end_time: period1.end_time
      )
    end

    let(:participant1_nonoverlap_period) do
      participant.awake_periods.build(
        start_time: period2.start_time,
        end_time: period2.end_time
      )
    end

    let(:scoped_awake_periods) do
      AwakePeriod.periods_for(
        Date.new(2014, 6, 20), Date.new(2014, 6, 22)
      )
    end

    it "prevents overlapping periods for a participant" do
      expect(participant1_overlap_period).not_to be_valid
    end

    it "allows overlapping periods for different participants" do
      expect(participant1_nonoverlap_period).to be_valid
    end

    it ".periods_for returns activity periods for a specified range" do
      expect(scoped_awake_periods.count).to eq 0

      AwakePeriod.create(
        participant: participant3,
        start_time: Date.new(2014, 6, 19),
        end_time: Date.new(2014, 6, 20))
      AwakePeriod.create(
        participant: participant3,
        start_time: Date.new(2014, 6, 20),
        end_time: Date.new(2014, 6, 21))
      AwakePeriod.create(
        participant: participant3,
        start_time: Date.new(2014, 6, 21),
        end_time: Date.new(2014, 6, 22))
      AwakePeriod.create(
        participant: participant3,
        start_time: Date.new(2014, 6, 22),
        end_time: Date.new(2014, 6, 23))

      expect(scoped_awake_periods.count).to eq 2
    end

    it ".unfinished_awake_periods returns awake periods for which there are no activities with corresponding start_time" do
      unfinished_awake_periods_count = participant3.unfinished_awake_periods.count
      AwakePeriod.create(
        participant: participant3,
        start_time: Date.new(2014, 6, 19),
        end_time: Date.new(2014, 6, 20))

      expect(participant3.unfinished_awake_periods.count).to eq unfinished_awake_periods_count + 1

      Activity.create(
        participant: participant3,
        activity_type: activity_types(:jogging),
        start_time: Date.new(2014, 6, 19),
        end_time: Date.new(2014, 6, 20))

      expect(participant3.unfinished_awake_periods.count).to eq unfinished_awake_periods_count
    end
  end
end
