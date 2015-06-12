require "rails_helper"

describe PhqStepping do
  let(:low_assessments) { Hash[Time.zone.today, 1, Time.zone.today - 14.days, 2] }
  let(:high_range_1_assessments) { Hash[Time.zone.today, 17, Time.zone.today - 14.days, 18] }
  let(:high_range_2_assessments) { Hash[Time.zone.today, 15, Time.zone.today - 14.days, 16] }
  let(:high_range_3_assessments) { Hash[Time.zone.today, 12, Time.zone.today - 14.days, 11, Time.zone.today - 49.days, 9] }
  let(:priority_check) do
    Hash[
      Time.zone.today, 3,
      Time.zone.today - 1.week, 3,
      Time.zone.today - 3.weeks, 17,
      Time.zone.today - 19.weeks, 9
    ]
  end

  let(:specific_week_three) do
    assessment_week_3 = PhqAssessment.new
    assessment_week_3.q1 = 3
    assessment_week_3.q2 = 0
    assessment_week_3.q3 = 0
    assessment_week_3.q4 = 0
    assessment_week_3.q5 = 0
    assessment_week_3.q6 = 0
    # Missing 7,8,9
    [Time.zone.today - 1.week, assessment_week_3]
  end

  let(:specific_week_four) do
    assessment_week_4 = PhqAssessment.new
    assessment_week_4.q1 = 3
    assessment_week_4.q2 = 0
    assessment_week_4.q3 = 0
    assessment_week_4.q4 = 0
    assessment_week_4.q5 = 0
    # Missing 6,7,8,9
    [Time.zone.today, assessment_week_4]
  end

  describe "PHQ Stepping Algorithm" do
    it ".consecutive_low_weeks? returns true if two consecutive weeks are low" do
      phq_low_four = PhqStepping.new(low_assessments, PhqStepping::EARLIEST_ELIGIBLE_STEPPING_WEEK)
      phq_low_five = PhqStepping.new(low_assessments, PhqStepping::EARLIEST_ELIGIBLE_STEPPING_WEEK + 1)
      expect(phq_low_four.instance_eval { consecutive_low_weeks? }).to eq true
      expect(phq_low_five.instance_eval { consecutive_low_weeks? }).to eq true
    end

    it ".consecutive_high_weeks? returns true if two consecutive weeks are high (Weeks 4 - 8)" do
      NEXT_WEEK = PhqStepping::EARLIEST_ELIGIBLE_STEPPING_WEEK + 1
      phq_high_four = PhqStepping.new(high_range_1_assessments, PhqStepping::EARLIEST_ELIGIBLE_STEPPING_WEEK)
      phq_high_five = PhqStepping.new(high_range_1_assessments, NEXT_WEEK)
      phq_mid_five = PhqStepping.new(high_range_2_assessments, NEXT_WEEK)
      expect(phq_high_four.instance_eval { consecutive_high_weeks? }).to eq true
      expect(phq_high_five.instance_eval { consecutive_high_weeks? }).to eq true
      expect(phq_mid_five.instance_eval { consecutive_high_weeks? }).to eq false
    end

    it ".consecutive_high_weeks? returns true if two consecutive weeks are high (Weeks 9 - 13)" do
      phq_high_nine = PhqStepping.new(high_range_1_assessments, 9)
      phq_high_ten = PhqStepping.new(high_range_1_assessments, 10)
      phq_high_eleven = PhqStepping.new(high_range_2_assessments, 11)
      phq_mid_twelve = PhqStepping.new(high_range_3_assessments, 12)
      expect(phq_high_nine.instance_eval { consecutive_high_weeks? }).to eq true
      expect(phq_high_ten.instance_eval { consecutive_high_weeks? }).to eq true
      expect(phq_high_eleven.instance_eval { consecutive_high_weeks? }).to eq true
      expect(phq_mid_twelve.instance_eval { consecutive_high_weeks? }).to eq false
    end

    it ".consecutive_high_weeks? returns true if two consecutive weeks are high (Weeks 14+)" do
      phq_high_fourteen = PhqStepping.new(high_range_1_assessments, 14)
      phq_high_fifteen = PhqStepping.new(high_range_1_assessments, 15)
      phq_high_sixteen = PhqStepping.new(high_range_2_assessments, 16)
      phq_high_seventeen = PhqStepping.new(high_range_3_assessments, 17)
      expect(phq_high_fourteen.instance_eval { consecutive_high_weeks? }).to eq true
      expect(phq_high_fifteen.instance_eval { consecutive_high_weeks? }).to eq true
      expect(phq_high_sixteen.instance_eval { consecutive_high_weeks? }).to eq true
      expect(phq_high_seventeen.instance_eval { consecutive_high_weeks? }).to eq true
    end

    it "handles when no assessments were completed" do
      phq_none = PhqStepping.new(nil, 5)
      expect(phq_none.suggestion).to eq "YES*"
      expect(phq_none.step).to eq nil
      expect(phq_none.stay).to eq nil
      expect(phq_none.release).to eq nil
    end

    it "handles when its too early to run the algorithm" do
      phq_early = PhqStepping.new(Hash[Time.zone.today, 17], 1)
      expect(phq_early.suggestion).to eq "No; Too Early"
      expect(phq_early.step).to eq nil
      expect(phq_early.stay).to eq nil
      expect(phq_early.release).to eq nil
    end

    it "handles edge case: on week 'earliest eligible stepping', no previous assessments" do
      phq_week_4_no_past = PhqStepping.new(Hash[Time.zone.today, 17], PhqStepping::EARLIEST_ELIGIBLE_STEPPING_WEEK)
      expect(phq_week_4_no_past.suggestion).to eq "YES*"
      expect(phq_week_4_no_past.step).to eq nil
      expect(phq_week_4_no_past.stay).to eq nil
      expect(phq_week_4_no_past.release).to eq nil
    end

    it "handles edge case: on week 'earliest eligible stepping', high assessments" do
      phq_week_4_past = PhqStepping.new(Hash[Time.zone.today - 1.week, 17], PhqStepping::EARLIEST_ELIGIBLE_STEPPING_WEEK)
      expect(phq_week_4_past.suggestion).to eq "YES"
      expect(phq_week_4_past.step).to eq true
      expect(phq_week_4_past.stay).to eq nil
      expect(phq_week_4_past.release).to eq nil
    end

    it "handles edge case: on week 'earliest eligible stepping', low assessments" do
      phq_week_4_past = PhqStepping.new(Hash[Time.zone.today - 1.week, 3], PhqStepping::EARLIEST_ELIGIBLE_STEPPING_WEEK)
      expect(phq_week_4_past.suggestion).to eq "No - Low Scores"
      expect(phq_week_4_past.step).to eq false
      expect(phq_week_4_past.stay).to eq nil
      expect(phq_week_4_past.release).to eq true
    end

    it "handles edge case: on week 'earliest eligible stepping', mid-range assessments" do
      phq_week_4_past_mid = PhqStepping.new(Hash[Time.zone.today - 1.week, 9], PhqStepping::EARLIEST_ELIGIBLE_STEPPING_WEEK)
      expect(phq_week_4_past_mid.step).to eq false
      expect(phq_week_4_past_mid.stay).to eq nil
      expect(phq_week_4_past_mid.release).to eq false
    end

    it "handles edge case: on week 9, no previous assessments" do
      phq_week_9_no_past = PhqStepping.new(Hash[Time.zone.today, 17], 9)
      expect(phq_week_9_no_past.step).to eq nil
      expect(phq_week_9_no_past.stay).to eq nil
      expect(phq_week_9_no_past.release).to eq nil
    end

    it "handles edge case: on week 9, high assessments" do
      phq_week_9_past = PhqStepping.new(Hash[Time.zone.today - 1.week, 17, Time.zone.today - 8.weeks, 9], 9)
      expect(phq_week_9_past.step).to eq true
      expect(phq_week_9_past.stay).to eq nil
      expect(phq_week_9_past.release).to eq nil
    end

    it "handles edge case: on week 9, one high, one low assessment" do
      phq_week_9_past = PhqStepping.new(Hash[Time.zone.today - 1.week, 15, Time.zone.today - 8.weeks, 9], 9)
      expect(phq_week_9_past.step).to eq false
      expect(phq_week_9_past.stay).to eq nil
      expect(phq_week_9_past.release).to eq false
    end

    it "handles edge case: on week 9, low assessments" do
      phq_week_9_past = PhqStepping.new(Hash[Time.zone.today - 1.week, 3, Time.zone.today - 8.weeks, 9], 9)
      expect(phq_week_9_past.step).to eq false
      expect(phq_week_9_past.stay).to eq nil
      expect(phq_week_9_past.release).to eq true
    end

    it "handles edge case: on week 9, mid-range assessments" do
      phq_week_9_past_mid = PhqStepping.new(Hash[Time.zone.today - 1.week, 9, Time.zone.today - 8.weeks, 9], 9)
      expect(phq_week_9_past_mid.step).to eq false
      expect(phq_week_9_past_mid.stay).to eq nil
      expect(phq_week_9_past_mid.release).to eq false
    end

    ###

    it "handles edge case: on week 14, no previous assessments" do
      phq_week_14_no_past = PhqStepping.new(Hash[Time.zone.today, 17], 14)
      expect(phq_week_14_no_past.step).to eq nil
      expect(phq_week_14_no_past.stay).to eq nil
      expect(phq_week_14_no_past.release).to eq nil
    end

    it "handles edge case: on week 14, high assessments" do
      phq_week_14_past = PhqStepping.new(Hash[Time.zone.today - 1.week, 17, Time.zone.today - 13.weeks, 14], 14)
      expect(phq_week_14_past.step).to eq true
      expect(phq_week_14_past.stay).to eq nil
      expect(phq_week_14_past.release).to eq nil
    end

    it "handles edge case: on week 14, one high, one low assessment" do
      phq_week_14_past = PhqStepping.new(Hash[Time.zone.today - 1.week, 12, Time.zone.today - 13.weeks, 9], 14)
      expect(phq_week_14_past.suggestion).to eq "No*"
      expect(phq_week_14_past.step).to eq false
      expect(phq_week_14_past.stay).to eq false
      expect(phq_week_14_past.release).to eq false
    end

    it "handles edge case: on week 14, low assessments" do
      phq_week_14_past = PhqStepping.new(Hash[Time.zone.today - 1.week, 3, Time.zone.today - 13.weeks, 9], 14)
      expect(phq_week_14_past.step).to eq false
      expect(phq_week_14_past.stay).to eq false
      expect(phq_week_14_past.release).to eq true
    end

    it "handles edge case: on week 14, mid-range assessments" do
      phq_week_14_past_mid = PhqStepping.new(Hash[Time.zone.today - 1.week, 9, Time.zone.today - 13.weeks, 9], 14)
      expect(phq_week_14_past_mid.step).to eq false
      expect(phq_week_14_past_mid.stay).to eq true
      expect(phq_week_14_past_mid.release).to eq false
    end

    it "high scores take priority over low scores" do
      phq_week_priority_check = PhqStepping.new(priority_check, 20)
      expect(phq_week_priority_check.suggestion).to eq "YES"
      expect(phq_week_priority_check.step).to eq true
      expect(phq_week_priority_check.stay).to eq nil
      expect(phq_week_priority_check.release).to eq nil
    end

    it "Fills in missing values for 3 or less missing answers in a single phq assessment" do
      phq_fill_in_answers = PhqStepping.new([specific_week_three], PhqStepping::EARLIEST_ELIGIBLE_STEPPING_WEEK)
      expect(phq_fill_in_answers.suggestion).to eq "No*"
      expect(phq_fill_in_answers.step).to eq false
      expect(phq_fill_in_answers.stay).to eq nil
      expect(phq_fill_in_answers.release).to eq false
    end

    it "Cancels if 4 or more missing answers in a single assessment" do
      phq_too_many_missing = PhqStepping.new([specific_week_three, specific_week_four], PhqStepping::EARLIEST_ELIGIBLE_STEPPING_WEEK)
      expect(phq_too_many_missing.suggestion).to eq "Consult - Missing Data"
      expect(phq_too_many_missing.step).to eq nil
      expect(phq_too_many_missing.stay).to eq nil
      expect(phq_too_many_missing.release).to eq nil
    end
  end
end
