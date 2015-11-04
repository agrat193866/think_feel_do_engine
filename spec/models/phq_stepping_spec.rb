require "rails_helper"

describe PhqStepping do
  let(:today) { Date.current }
  let(:last_week) { today - 1.week }
  let(:discontinue_score) { 4 }
  let(:stay_score) { 9 }
  let(:first_period_highest_mid_range_score) { 16 }
  let(:first_period_step_score) { first_period_highest_mid_range_score + 1 }
  let(:second_period_highest_mid_range_score) { 12 }
  let(:second_period_step_score) { second_period_highest_mid_range_score + 1 }
  let(:third_period_highest_mid_range_score) { 12 }
  let(:third_period_step_score) { third_period_highest_mid_range_score + 1 }

  def week_in_study(week)
    Date.current - (week - 1).weeks
  end

  describe "PHQ Stepping Algorithm" do
    describe "when not eligible for stepping" do
      let(:complete_phq_assesment) do
        PhqAssessment.new(q1: 3, q2: 0, q3: 0, q4: 0, q5: 0, q6: 0, q7: 0, q8: 0, q9: 0)
      end

      describe "when its too early to run the algorithm" do
        let(:phq_stepping) do
          PhqStepping.new(Hash[today, 17], week_in_study(3))
        end

        it "sets phq stepping attributes" do
          expect(phq_stepping.detailed_suggestion)
            .to eq "Stay on i-CBT; Too early to determine stepping."
          expect(phq_stepping.release).to eq nil
          expect(phq_stepping.stay).to eq nil
          expect(phq_stepping.step).to eq nil
          expect(phq_stepping.suggestion).to eq "No; Too Early"
          expect(phq_stepping.urgency).to eq "warning"
        end
      end

      describe "when no assessments have been completed" do
        let(:phq_stepping) do
          PhqStepping.new(nil, week_in_study(5))
        end

        it "sets phq stepping attributes" do
          expect(phq_stepping.detailed_suggestion)
            .to eq "No assessments passed to the algorithm. An error may have occurred"
          expect(phq_stepping.release).to eq nil
          expect(phq_stepping.stay).to eq nil
          expect(phq_stepping.step).to eq nil
          expect(phq_stepping.suggestion).to eq "YES*"
          expect(phq_stepping.urgency).to eq "danger"
        end
      end

      describe "when baseline doesn't exist" do
        let(:phq_stepping) do
          PhqStepping
            .new(Hash[today, 17, today - 14.days, 18], week_in_study(9))
        end

        it "sets phq stepping attributes" do
          expect(phq_stepping.detailed_suggestion)
            .to eq "Patient has no completed assessments until after week 3. "\
                   "Stepping algorithm not run; please use discretion."
          expect(phq_stepping.release).to eq nil
          expect(phq_stepping.stay).to eq nil
          expect(phq_stepping.step).to eq nil
          expect(phq_stepping.suggestion).to eq "YES*"
          expect(phq_stepping.urgency).to eq "danger"
        end
      end

      describe "when high and low scored assessments have been submitted" do
        let(:phq_stepping) do
          PhqStepping
            .new(Hash[
              today, 3,
              last_week, 3,
              today - 3.weeks, 17,
              today - 19.weeks, 9
            ], week_in_study(20))
        end

        it "prioritizes high assessment scores over low assesment scores" do
          expect(phq_stepping.detailed_suggestion)
            .to eq "Step to t-CBT"
          expect(phq_stepping.release).to eq nil
          expect(phq_stepping.stay).to eq nil
          expect(phq_stepping.step).to eq true
          expect(phq_stepping.suggestion).to eq "YES"
          expect(phq_stepping.urgency).to eq "danger"
        end
      end

      describe "when three or fewer missing responses exist for a single phq assessment" do
        let(:incomplete_phq_assesment) do
          # Missing responses to questions 7, 8, 9
          PhqAssessment.new(q1: 3, q2: 0, q3: 0, q4: 0, q5: 0, q6: 0)
        end

        let(:phq_stepping) do
          PhqStepping
            .new(
              [
                [last_week, incomplete_phq_assesment],
                [today - 2.weeks, complete_phq_assesment]
              ],
              week_in_study(5))
        end

        it "estimates the missing responses when making suggestions" do
          expect(phq_stepping.detailed_suggestion)
            .to eq "Stay on i-CBT"
          expect(phq_stepping.release).to eq false
          expect(phq_stepping.stay).to eq true
          expect(phq_stepping.step).to eq false
          expect(phq_stepping.suggestion).to eq "No"
          expect(phq_stepping.urgency).to eq "success"
        end
      end

      describe "when four or more missing responses exist for a single phq assessment" do
        let(:incomplete_phq_assesment) do
          # Missing responses to questions 6, 7, 8, 9
          PhqAssessment.new(q1: 3, q2: 0, q3: 0, q4: 0, q5: 0)
        end

        let(:phq_stepping) do
          PhqStepping
            .new(
              [
                [last_week, incomplete_phq_assesment],
                [today - 2.weeks, complete_phq_assesment]
              ],
              week_in_study(5))
        end

        it "doesn't make any recommendations" do
          expect(phq_stepping.detailed_suggestion)
            .to eq "One or more assessments are missing more than than three answers. "\
                   "Stepping should be determined via consultation instead."
          expect(phq_stepping.release).to eq nil
          expect(phq_stepping.stay).to eq nil
          expect(phq_stepping.step).to eq nil
          expect(phq_stepping.suggestion).to eq "Consult - Missing Data"
          expect(phq_stepping.urgency).to eq "warning"
        end
      end
    end

    describe "when eligible for stepping" do
      describe "weeks 4 - 8 with high threshold of 17 pts" do
        let(:previous_highest_mid_range_score) { first_period_highest_mid_range_score }
        let(:current_highest_mid_range_score) { first_period_highest_mid_range_score }
        let(:previous_step_score) { first_period_step_score }
        let(:current_step_score) { first_period_step_score }

        describe "edge week (i.e., week 4)" do
          let(:study_start_date) { week_in_study(4) }

          describe "when two consecutive week scores are low (i.e., < 5 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, discontinue_score, last_week, discontinue_score],
                  study_start_date)
            end

            it "recommends releasing" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT or schedule post engagement call"
              expect(phq_stepping.release).to eq true
              expect(phq_stepping.suggestion).to eq "No - Low Scores"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are mid-range" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_highest_mid_range_score, last_week, previous_highest_mid_range_score],
                  study_start_date)
            end

            it "recommends only a suggestion" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT; Using data from last period as well"
              expect(phq_stepping.release).to eq false
              expect(phq_stepping.stay).to eq nil
              expect(phq_stepping.step).to eq false
              expect(phq_stepping.suggestion).to eq "No*"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are high (i.e., >= 17 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_step_score, last_week, previous_step_score],
                  study_start_date)
            end

            it "recommends stepping" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Step to t-CBT"
              expect(phq_stepping.step).to eq true
              expect(phq_stepping.suggestion).to eq "YES"
              expect(phq_stepping.urgency).to eq "danger"
            end
          end
        end

        describe "non-edge week (example: week 6)" do
          let(:study_start_date) { week_in_study(6) }

          describe "#results" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, discontinue_score, last_week, discontinue_score, today - 4.weeks, stay_score],
                  study_start_date)
            end

            it "returns current week" do
              expect(phq_stepping.results[:current_week]).to eq 6
            end

            it "returns correct hash of limits" do
              expect(phq_stepping.results[:lower_limit]).to eq 5
              expect(phq_stepping.results[:range_start]).to eq 4
              expect(phq_stepping.results[:upper_limit]).to eq current_step_score
            end
          end

          describe "when two consecutive week scores are low (i.e., < 5 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(Hash[today, discontinue_score, last_week, discontinue_score, today - 4.weeks, discontinue_score], study_start_date)
            end

            it "recommends releasing" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT or schedule post engagement call"
              expect(phq_stepping.release).to eq true
              expect(phq_stepping.suggestion).to eq "No - Low Scores"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are mid-range (i.e., 5 - 16 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_highest_mid_range_score, last_week, current_highest_mid_range_score, today - 4.weeks, discontinue_score],
                  study_start_date)
            end

            it "recommends staying" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT"
              expect(phq_stepping.stay).to eq true
              expect(phq_stepping.suggestion).to eq "No"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are high (i.e., >= 17 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_step_score, last_week, current_step_score, today - 4.weeks, discontinue_score],
                  study_start_date)
            end

            it "recommends stepping" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Step to t-CBT"
              expect(phq_stepping.step).to eq true
              expect(phq_stepping.suggestion).to eq "YES"
              expect(phq_stepping.urgency).to eq "danger"
            end
          end
        end
      end

      describe "weeks 9 - 13 with threshold of 13 pts" do
        let(:previous_highest_mid_range_score) { first_period_highest_mid_range_score }
        let(:current_highest_mid_range_score) { second_period_highest_mid_range_score }
        let(:previous_step_score) { first_period_step_score }
        let(:current_step_score) { second_period_step_score }

        describe "edge week (i.e., week 9)" do
          let(:study_start_date) { week_in_study(9) }

          describe "when two consecutive week scores are low (i.e., < 5 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, discontinue_score, last_week, discontinue_score, today - 8.weeks, discontinue_score],
                  study_start_date)
            end

            it "recommends releasing" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT or schedule post engagement call"
              expect(phq_stepping.release).to eq true
              expect(phq_stepping.suggestion).to eq "No - Low Scores"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are mid-range (i.e., 5 - 12 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_highest_mid_range_score, last_week, previous_highest_mid_range_score, today - 8.weeks, discontinue_score],
                  study_start_date)
            end

            it "recommends only a suggestion" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT; Using data from last period as well"
              expect(phq_stepping.release).to eq false
              expect(phq_stepping.stay).to eq nil
              expect(phq_stepping.step).to eq false
              expect(phq_stepping.suggestion).to eq "No*"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are high (i.e., >= 13 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_step_score, last_week, previous_step_score, today - 8.weeks, discontinue_score],
                  study_start_date)
            end

            it "recommends stepping" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Step to t-CBT"
              expect(phq_stepping.step).to eq true
              expect(phq_stepping.suggestion).to eq "YES"
              expect(phq_stepping.urgency).to eq "danger"
            end
          end
        end

        describe "non-edge week (example: week 10)" do
          let(:study_start_date) { week_in_study(10) }

          describe "#results" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, discontinue_score, last_week, discontinue_score, today - 3.weeks, discontinue_score],
                  study_start_date)
            end

            it "returns correct hash of limits" do
              expect(phq_stepping.results[:lower_limit]).to eq discontinue_score + 1
              expect(phq_stepping.results[:range_start]).to eq 9
              expect(phq_stepping.results[:upper_limit]).to eq current_step_score
            end
          end

          describe "when two consecutive week scores are low (i.e., < 5 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, discontinue_score, last_week, discontinue_score, today - 8.weeks, discontinue_score],
                  study_start_date)
            end

            it "recommends releasing" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT or schedule post engagement call"
              expect(phq_stepping.release).to eq true
              expect(phq_stepping.suggestion).to eq "No - Low Scores"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are mid-range (i.e., 5 - 12 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_highest_mid_range_score, last_week, current_highest_mid_range_score, today - 8.weeks, discontinue_score],
                  study_start_date)
            end

            it "recommends staying" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT"
              expect(phq_stepping.stay).to eq true
              expect(phq_stepping.suggestion).to eq "No"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are high (i.e., >= 13 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_step_score, last_week, current_step_score, today - 8.weeks, discontinue_score],
                  study_start_date)
            end

            it "recommends stepping" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Step to t-CBT"
              expect(phq_stepping.step).to eq true
              expect(phq_stepping.suggestion).to eq "YES"
              expect(phq_stepping.urgency).to eq "danger"
            end
          end
        end
      end

      describe "weeks 14+" do
        let(:previous_highest_mid_range_score) { second_period_highest_mid_range_score }
        let(:current_highest_mid_range_score) { third_period_highest_mid_range_score }
        let(:previous_step_score) { second_period_step_score }
        let(:current_step_score) { third_period_step_score }

        describe "previous edge week (i.e., week 14)" do
          let(:study_start_date) { week_in_study(14) }

          describe "when two consecutive week scores are low (i.e., < 5 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, discontinue_score, last_week, discontinue_score, today - 11.week, stay_score],
                  study_start_date)
            end

            it "recommends releasing" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT or schedule post engagement call"
              expect(phq_stepping.release).to eq true
              expect(phq_stepping.suggestion).to eq "No - Low Scores"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are mid-range (i.e., 5 - 12 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_highest_mid_range_score, last_week, previous_highest_mid_range_score, today - 11.week, stay_score],
                  study_start_date)
            end

            it "recommends staying" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT"
              expect(phq_stepping.stay).to eq true
              expect(phq_stepping.suggestion).to eq "No"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are high (i.e., >= 13 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_step_score, last_week, previous_step_score, today - 11.week, stay_score],
                  study_start_date)
            end

            it "recommends stepping" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Step to t-CBT"
              expect(phq_stepping.step).to eq true
              expect(phq_stepping.suggestion).to eq "YES"
              expect(phq_stepping.urgency).to eq "danger"
            end
          end
        end

        describe "non-edge week (example: week 15)" do
          let(:study_start_date) { week_in_study(15) }

          describe "#results" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, 1, last_week, 4, today - 11.week, stay_score],
                  study_start_date)
            end

            it "returns correct hash of limits" do
              expect(phq_stepping.results[:lower_limit]).to eq discontinue_score + 1
              expect(phq_stepping.results[:range_start]).to eq 9
              expect(phq_stepping.results[:upper_limit]).to eq current_step_score
            end
          end

          describe "when two consecutive week scores are low (i.e., < 5 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, discontinue_score, last_week, discontinue_score, today - 13.weeks, stay_score],
                  study_start_date)
            end

            it "recommends releasing" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT or schedule post engagement call"
              expect(phq_stepping.release).to eq true
              expect(phq_stepping.suggestion).to eq "No - Low Scores"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are mid-range (i.e., 5 - 12 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_highest_mid_range_score, last_week, current_highest_mid_range_score, today - 13.weeks, stay_score],
                  study_start_date)
            end

            it "recommends staying" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Stay on i-CBT"
              expect(phq_stepping.stay).to eq true
              expect(phq_stepping.suggestion).to eq "No"
              expect(phq_stepping.urgency).to eq "success"
            end
          end

          describe "when two consecutive week scores are high (i.e., >= 13 pts)" do
            let(:phq_stepping) do
              PhqStepping
                .new(
                  Hash[today, current_step_score, last_week, current_step_score, today - 13.weeks, stay_score],
                  study_start_date)
            end

            it "recommends stepping" do
              expect(phq_stepping.detailed_suggestion)
                .to eq "Step to t-CBT"
              expect(phq_stepping.step).to eq true
              expect(phq_stepping.suggestion).to eq "YES"
              expect(phq_stepping.urgency).to eq "danger"
            end
          end
        end
      end
    end
  end
end
