require "rails_helper"

RSpec.describe Activity do
  fixtures :all

  describe "scopes" do
    let(:participant) { participants(:participant1) }

    def sleeping(attributes = {})
      Activity.create!({
        participant: participant,
        activity_type: activity_types(:sleeping)
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

    # To Do: See note in activity.rb
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

    # To Do: See note in activity.rb
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
      it "returns a proportion completed activities as a percent" do
        period_start = Time.local(2016, 4, 23, 21)
        period_end = Time.local(2016, 4, 23, 24)

        sleeping(actual_accomplishment_intensity: 5,
                 start_time: period_start + 1.hour)
        sleeping(actual_accomplishment_intensity: 6,
                 is_complete: true,
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

    describe ".scheduled" do
      it "returns activities where is_scheduled is true" do
        scheduled_activities = Activity.scheduled

        expect(scheduled_activities.load).not_to be_empty
        scheduled_activities.each do |a|
          expect(a.is_scheduled).to eq true
        end
      end
    end
  end

  describe "instance methods" do
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
      Activity.create!({
        participant: participants(:participant1),
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

      expect(activity.errors.full_messages).to include(
        "Actual accomplishment intensity can't be updated because activity " \
        "is not in the past."
      )
    end

    it "creates an error message when updating the actual pleasure" do
      activity.update(actual_pleasure_intensity: 1)

      expect(activity.errors.full_messages).to include(
        "Actual pleasure intensity can't be updated because activity is not " \
        "in the past."
      )
    end
  end
end
