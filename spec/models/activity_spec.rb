require "rails_helper"

RSpec.describe Activity do
  fixtures :all

  describe "scopes" do
    let(:participant) { participants(:participant1) }

    def sleeping(attributes = {})
      Activity.create!({ participant: participant,
                         activity_type: activity_types(:sleeping),
                         predicted_accomplishment_intensity: 5,
                         predicted_pleasure_intensity: 5,
                         actual_accomplishment_intensity: 5,
                         actual_pleasure_intensity: 5
                       }.merge(attributes))
    end

    describe ".for_day" do
      it "returns only the activities for that day" do
        expect(Activity.for_day(Time.local(2016, 1, 15)).count).to eq 0

        sleeping start_time: Time.local(2016, 1, 15, 22)
        sleeping start_time: Time.local(2016, 1, 16, 22)

        expect(Activity.for_day(Time.local(2016, 1, 15)).count).to eq 1
      end
    end

    describe ".with_actual_ratings" do
      it "returns all activities that have actual intensity ratings" do
        expect do
          sleeping(
            actual_accomplishment_intensity: 5,
            actual_pleasure_intensity: 5)
        end.to change { Activity.with_actual_ratings.count }.by(1)
      end
    end

    describe ".reviewed_and_complete" do
      it "returns all activities that have been reviewed and have predicted intensities, acutal intensities, and it was reviewed" do
        expect do
          sleeping(
            predicted_accomplishment_intensity: 5,
            predicted_pleasure_intensity: 5,
            actual_accomplishment_intensity: 5,
            actual_pleasure_intensity: 5,
            is_reviewed: true)
        end.to change { Activity.reviewed_and_complete.count }.by(1)
      end
    end

    describe ".reviewed_and_incomplete" do
      it "returns all activities that have been reviewed and have predicted intensities, but not actual intensities" do
        expect do
          sleeping(
            predicted_accomplishment_intensity: 5,
            predicted_pleasure_intensity: 5,
            actual_accomplishment_intensity: nil,
            actual_pleasure_intensity: nil,
            is_reviewed: true)
        end.to change { Activity.reviewed_and_incomplete.count }.by(1)
      end
    end

    describe ".monitored" do
      it "returns activities that have not been reviwed and have predicted intensities, but not actual intensities " do
        expect do
          sleeping(
            predicted_accomplishment_intensity: 5,
            predicted_pleasure_intensity: 5,
            actual_accomplishment_intensity: nil,
            actual_pleasure_intensity: nil,
            is_reviewed: false)
        end.to change { Activity.monitored.count }.by(1)
      end
    end

    describe ".accomplished" do
      it "returns actitivies that have an actual accomplishment >= to a cutoff" do
        expect do
          sleeping actual_accomplishment_intensity: 5
          sleeping actual_accomplishment_intensity: 6
          sleeping actual_accomplishment_intensity: 10
        end.to change { Activity.accomplished.count }.by(2)
      end
    end

    describe ".pleasurable" do
      it "returns actitivies that have an actual pleasure >= to a cutoff" do
        expect do
          sleeping actual_pleasure_intensity: 5
          sleeping actual_pleasure_intensity: 6
          sleeping actual_pleasure_intensity: 10
        end.to change { Activity.pleasurable.count }.by(2)
      end
    end

    # To Do: See note in patient_activity.rb
    describe ".in_the_future" do
      it "returns actitivies that are planned for the future" do
        expect do
          sleeping start_time: Time.current.advance(hours: 1)
          sleeping start_time: Time.current.advance(hours: -1)
        end.to change { Activity.in_the_future.count }.by(1)
      end
    end

    describe ".in_the_past" do
      it "returns actitivies have taken place in the past" do
        expect do
          sleeping start_time: Time.current.advance(hours: -1)
          sleeping start_time: Time.current
        end.to change { Activity.in_the_past.count }.by(1)
      end
    end

    describe ".last_seven_days" do
      it "returns actitivies have taken place during the last 7 days" do
        expect do
          sleeping start_time: Time.current.advance(days: -7)
          sleeping start_time: Time.current.advance(days: -8)
        end.to change { Activity.last_seven_days.count }.by(1)
      end
    end

    # To Do: See note in patient_activity.rb
    describe ".unscheduled_or_in_the_future" do
      it "returns actitivies are unscheduled or in the future" do
        expect do
          sleeping start_time: Time.current.advance(days: 1)
          sleeping start_time: nil
          sleeping start_time: Time.current.advance(days: -1)
        end.to change { Activity.unscheduled_or_in_the_future.count }.by(2)
      end
    end

    describe ".during" do
      it "returns actitivies that were started and completed during a period" do
        period_start = Time.local(2016, 1, 15, 22)
        period_end = Time.local(2016, 1, 15, 23)

        expect do
          sleeping start_time: period_start
          sleeping start_time: period_start - 1.hour
          sleeping start_time: period_end
        end.to change { Activity.during(period_start, period_end).count }.by(1)
      end
    end

    describe ".completion_score" do
      it "returns a proportion of 'reviewed and completed' activities as a percent" do
        period_start = Time.local(2016, 4, 23, 21)
        period_end = Time.local(2016, 4, 23, 24)

        sleeping(start_time: period_start + 1.hour)
        sleeping(is_reviewed: true,
                 start_time: period_end - 1.hour)

        expect(Activity.during(period_start, period_end).completion_score)
          .to eq(50)
      end

      it "returns zero if no activities are completed" do
        period_start = Time.local(2016, 1, 15, 21)
        period_end = Time.local(2016, 1, 15, 24)

        sleeping(actual_accomplishment_intensity: 5,
                 start_time: period_start + 1.hour)
        sleeping(actual_accomplishment_intensity: 6,
                 start_time: period_end - 1.hour)

        expect(Activity.during(period_start, period_end).completion_score)
          .to eq(0)
      end
    end

    describe ".unplanned" do
      it "returns activities without start_time or end_time" do
        unplanned_activities = Activity.unplanned

        expect(unplanned_activities.load).not_to be_empty
        unplanned_activities.each do |a|
          expect(a.start_time).to be_nil
          expect(a.end_time).to be_nil
        end
      end
    end

    describe ".planned" do
      it "returns activities have neither actual intensity rated and both predicted intensities rated" do
        planned_activities = Activity.planned

        expect(planned_activities.load).not_to be_empty
        planned_activities.each do |a|
          expect(a.planned?).to eq true
        end
      end
    end

    describe ".were_planned" do
      it "returns activities where both predicted intensities were rated" do
        were_planned = Activity.were_planned

        expect(were_planned.load).not_to be_empty
        were_planned.each do |a|
          expect(a.predicted_pleasure_intensity).to_not eq nil
          expect(a.predicted_accomplishment_intensity).to_not eq nil
        end
      end
    end
  end

  describe "instance methods" do
    describe "#update_as_reviewed" do
      let(:activity) { activities(:planned_activity0) }

      it "updates activity with is_reviewed to be true" do
        expect(activity.is_reviewed).to eq false

        activity.update_as_reviewed

        expect(activity.is_reviewed).to eq true
      end

      it "returns false if actual_accomplishment_intensity is nil" do
        activity.update_as_reviewed

        expect(activity).to_not be_valid
      end

      it "returns error messages if actual_accomplishment_intensity is nil" do
        activity.update_as_reviewed

        expect(
          activity
            .errors
            .full_messages
        ).to include("Actual accomplishment intensity can't be blank.")
      end

      it "returns false if actual_pleasure_intensity is nil" do
        activity.update_as_reviewed

        expect(activity).to_not be_valid
      end

      it "returns error messages if actual_accomplishment_intensity is nil" do
        activity.update_as_reviewed

        expect(
          activity
            .errors
            .full_messages
        ).to include("Actual pleasure intensity can't be blank.")
      end
    end

    describe "#monitored?" do
      def running(attributes = {})
        Activity.create!({ participant: participants(:participant1),
                           activity_type: activity_types(:jogging)
                         }.merge(attributes))
      end

      it "returns false if the activity has been reviewed" do
        expect(running(is_reviewed: true).monitored?).to be false
      end

      it "returns false if the activity has predictions" do
        expect(
          running(predicted_accomplishment_intensity: 2,
                  predicted_pleasure_intensity: 8
                 ).monitored?).to be false
      end

      it "returns false if actual intensities don't exist" do
        expect(running(actual_accomplishment_intensity: nil,
                       actual_pleasure_intensity: nil
                      ).monitored?).to be false
      end

      it "returns true if has actual ratings but not reviewed" do
        expect(running(actual_accomplishment_intensity: 5,
                       actual_pleasure_intensity: 3
                      ).monitored?).to be true
      end
    end

    describe "#planned?" do
      def running(attributes = {})
        Activity.create!({ participant: participants(:participant1),
                           activity_type: activity_types(:jogging)
                         }.merge(attributes))
      end

      it "returns false if the activity it has been reviewed" do
        expect(running(is_reviewed: true).planned?).to be false
      end

      it "returns false if the activity has actual intensity ratings" do
        expect(running(actual_accomplishment_intensity: 5,
                       actual_pleasure_intensity: 3
                      ).planned?).to be false
      end

      it "returns false if predictions don't exist" do
        expect(running(predicted_accomplishment_intensity: nil,
                       predicted_pleasure_intensity: nil
                      ).planned?).to be false
      end

      it "returns true if has predictions but not reviewed" do
        expect(running(predicted_accomplishment_intensity: 5,
                       predicted_pleasure_intensity: 3
                      ).planned?).to be true
      end
    end

    describe "activity has predictions" do
      describe "#reviewed_and_complete?" do
        def running(attributes = {})
          Activity.create!({ participant: participants(:participant1),
                             activity_type: activity_types(:jogging),
                             is_reviewed: true,
                             predicted_accomplishment_intensity: 5,
                             predicted_pleasure_intensity: 3,
                             actual_accomplishment_intensity: 8,
                             actual_pleasure_intensity: 7
                           }.merge(attributes))
        end

        it "returns false if not reviewed" do
          expect(running(is_reviewed: false).reviewed_and_complete?).to be false
        end

        it "returns false if the activity does not have predicted intensity ratings" do
          expect(running(predicted_accomplishment_intensity: nil,
                         predicted_pleasure_intensity: nil
                        ).reviewed_and_complete?).to be false
        end

        it "returns false if the activity does not have actual intensity ratings" do
          expect(running(actual_accomplishment_intensity: nil,
                         actual_pleasure_intensity: nil
                        ).reviewed_and_complete?).to be false
        end

        it "returns true if it has predictions, actual intensity ratings, and is reviewed" do
          expect(running.reviewed_and_complete?).to be true
        end
      end

      describe "#reviewed_and_incomplete?" do
        def running(attributes = {})
          Activity.create!({ participant: participants(:participant1),
                             activity_type: activity_types(:jogging),
                             predicted_accomplishment_intensity: 5,
                             predicted_pleasure_intensity: 3,
                             is_reviewed: true
                           }.merge(attributes))
        end

        it "returns false if reviewed is false" do
          expect(running(is_reviewed: false).reviewed_and_incomplete?).to be false
        end

        it "returns false if the activity has actual intensity ratings" do
          expect(running(actual_accomplishment_intensity: 9,
                         actual_pleasure_intensity: 1
                        ).reviewed_and_incomplete?).to be false
        end

        it "returns false if the activity does not have predicted intensity ratings" do
          expect(running(predicted_accomplishment_intensity: nil,
                         predicted_pleasure_intensity: nil
                        ).reviewed_and_incomplete?).to be false
        end

        it "returns true if the activity is reviewed, has predictions, but no acutal intensity ratings" do
          expect(running.reviewed_and_incomplete?).to be true
        end
      end
    end

    describe "#status_label" do
      let(:sleeping) do
        Activity.create(
          participant: participants(:participant1),
          activity_type: activity_types(:sleeping))
      end

      it "returns 'Monitored' if the activity has been monitored" do
        allow(sleeping).to receive(:monitored?).and_return(true)

        expect(sleeping.status_label).to eq "Monitored"
      end

      it "returns 'Planned' if the activity has been planned" do
        allow(sleeping).to receive(:planned?).and_return(true)

        expect(sleeping.status_label).to eq "Planned"
      end

      it "returns 'Reviewed & Completed' if the activity has been Reviewed & Completed" do
        allow(sleeping).to receive(:reviewed_and_complete?).and_return(true)

        expect(sleeping.status_label).to eq "Reviewed & Completed"
      end

      it "returns whether an activity has been reviewed and is still incomplete" do
        allow(sleeping).to receive(:reviewed_and_incomplete?).and_return(true)

        expect(sleeping.status_label).to eq "Reviewed and did not complete"
      end
    end

    describe "#actual_editable?" do
      let(:activity) { activities(:planned_activity_today_1) }

      it "returns true after it has passed" do
        expect(activity).to be_actual_editable
      end

      it "returns false before it has passed" do
        expect(Activity.new(end_time: Time.current + 4.days))
          .not_to be_actual_editable
      end

      it "returns false without an end_time" do
        expect(activities(:unplanned_activity1)).not_to be_actual_editable
      end

      it "returns false if the activity has been reviewed and is incomplete" do
        allow(activity).to receive(:reviewed_and_incomplete?).and_return(true)

        expect(activity).not_to be_actual_editable
      end
    end

    describe "#intensity_difference" do
      let(:activity1) { activities(:planned_activity_today_1) }
      let(:activity2) { activities(:planned_activity_today_2) }
      let(:activity3) { activities(:planned_activity_today_3) }

      it "of accomplishment returns the difference of the predicted and actual" do
        expect(activity1.intensity_difference(:accomplishment)).to eq 5
      end

      it "of pleasure returns the difference of the predicted and actual" do
        expect(activity1.intensity_difference(:pleasure)).to eq 0
      end

      it "returns 'N/A' if no intensities are given" do
        expect(activity2.intensity_difference(:pleasure)).to eq "N/A"
      end

      it "returns 'N/A' if no predictions are not given" do
        expect(activity3.intensity_difference(:pleasure)).to eq "N/A"
      end
    end
  end

  describe "create activity type" do
    let(:title) { "prancing in the woods" }

    def create_activity!(attributes = {})
      Activity.create!({ participant: participants(:participant1),
                         start_time: Time.current
                       }.merge(attributes))
    end

    it "creates an activity type with an activity type title" do
      create_activity! activity_type_title: title

      expect(participants(:participant1).activity_types.exists?(title: title))
        .to be true
    end

    it "doesn't create an activity type without an activity type title" do
      expect { create_activity! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(participants(:participant1).activity_types.exists?(title: title))
        .to be false
    end
  end

  context "a future activity" do
    let(:activity) { activities(:planned_activity_today_4) }

    it "creates an error message when updating the actual accomplishment" do
      activity.update(actual_accomplishment_intensity: 1)

      expect(activity.errors.full_messages)
        .to include("Actual accomplishment intensity can't be updated because activity " \
                    "is not in the past.")
    end

    it "creates an error message when updating the actual pleasure" do
      activity.update(actual_pleasure_intensity: 1)

      expect(activity.errors.full_messages)
        .to include("Actual pleasure intensity can't be updated because activity is not " \
                    "in the past.")
    end
  end

  describe "#shared_description" do
    let(:participant) { participants(:participant1) }
    it "returns an item description" do
      activity = Activity.new(participant: participant,
                              activity_type: activity_types(:sleeping)
                              )
      expect(activity.shared_description).to eq("Activity: Sleeping")
    end
  end

  describe "validations" do
    let(:participant) { participants(:participant1) }

    def sleeping(attributes = {})
      Activity.new({ participant: participant,
                     activity_type: activity_types(:sleeping)
                   }.merge(attributes))
    end

    describe ".predicted_intensities" do
      it "returns false when validated if only predicted_accomplishment_intensity is set" do
        expect(
          sleeping(predicted_accomplishment_intensity: 4).tap(&:valid?).errors.full_messages
        ).to include("When predicting, you must predict both pleasure and accomplishment.")
      end

      it "returns false when validated if only predicted_pleasure_intensity is set" do
        expect(
          sleeping(predicted_pleasure_intensity: 4).tap(&:valid?).errors.full_messages
        ).to include("When predicting, you must predict both pleasure and accomplishment.")
      end
    end

    describe ".actual_intensities" do
      it "returns false when validated if only actual_accomplishment_intensity is set" do
        expect(
          sleeping(actual_accomplishment_intensity: 4).tap(&:valid?).errors.full_messages
        ).to include("When rating actual intensities, you must rate both pleasure and accomplishment.")
      end

      it "returns false when validated if only actual_pleasure_intensity is set" do
        expect(
          sleeping(actual_pleasure_intensity: 4).tap(&:valid?).errors.full_messages
        ).to include("When rating actual intensities, you must rate both pleasure and accomplishment.")
      end
    end
  end
end
