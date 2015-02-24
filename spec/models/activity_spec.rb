require "rails_helper"

describe Activity do
  fixtures [:participants, :activity_types, :activities]

  describe "model scopes" do
    let(:sleeping) { activity_types(:sleeping) }
    let(:participant) { participants(:participant1) }

    it ".for_day returns only the activities for that day" do
      expect(activities.count).to eq 0

      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.local(2016, 1, 15, 22))
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.local(2016, 1, 16, 22))
      activities = Activity.for_day(Time.local(2016, 1, 15))

      expect(activities.count).to eq 1
    end

    it ".accomplished returns actitivies that have an actual_accomplishment_intensity greater than or equal to a cutoff" do
      count = Activity.accomplished.count
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        actual_accomplishment_intensity: 5)
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        actual_accomplishment_intensity: 6)
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        actual_accomplishment_intensity: 10)

      expect(Activity.accomplished.count).to eq(count + 2)
    end

    it ".pleasureable returns actitivies that have an actual_pleasure_intensity greater than or equal to a cutoff" do
      count = Activity.pleasurable.count
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        actual_pleasure_intensity: 5)
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        actual_pleasure_intensity: 6)
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        actual_pleasure_intensity: 10)

      expect(Activity.pleasurable.count).to eq(count + 2)
    end

    # To Do: See note in activity.rb
    it ".in_the_future returns actitivies are planned for the future" do
      count = Activity.in_the_future.count
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.current.advance(hours: 1))
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        # start_time: Time.current
        start_time: Time.current.advance(hours: -1)
      )

      expect(Activity.in_the_future.count).to eq(count + 1)
    end

    it ".in_the_past returns actitivies have taken place in the past" do
      count = Activity.in_the_past.count
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.current.advance(hours: -1))
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.current)

      expect(Activity.in_the_past.count).to eq(count + 1)
    end

    it ".last_seven_days returns actitivies have taken place during the last 7 days" do
      count = Activity.last_seven_days.count
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.current.advance(days: -7))
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.current.advance(days: -8))

      expect(Activity.last_seven_days.count).to eq(count + 1)
    end

    # To Do: See note in activity.rb
    it ".unscheduled_or_in_the_future returns actitivies are unscheduled or in the future" do
      count = Activity.unscheduled_or_in_the_future.count
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.current.advance(days: 1))
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: nil)
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.current.advance(days: -1))

      expect(Activity.unscheduled_or_in_the_future.count).to eq(count + 2)
    end

    it ".during returns actitivies that were started and completed during a range of times" do
      count = Activity.during(Time.local(2016, 1, 15, 22), Time.local(2016, 1, 15, 23)).count
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.local(2016, 1, 15, 22))
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.local(2016, 1, 15, 21))
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        start_time: Time.local(2016, 1, 15, 23))

      expect(Activity.during(Time.local(2016, 1, 15, 22), Time.local(2016, 1, 15, 23)).count).to eq(count + 1)
    end
    it ".completion_score returns a proportion completed activities as a percent" do
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        actual_accomplishment_intensity: 5,
        start_time: Time.local(2016, 4, 23, 22))
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        actual_accomplishment_intensity: 6,
        is_complete: true,
        start_time: Time.local(2016, 4, 23, 23))

      activities = (Activity.during(Time.local(2016, 4, 23, 21), Time.local(2016, 4, 23, 24)))
      expect(activities.completion_score).to eq(50)
    end

    it ".completion_score returns zero if no activities are completed" do
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        actual_accomplishment_intensity: 5,
        start_time: Time.local(2016, 1, 15, 22))
      Activity.create(
        participant: participant,
        activity_type: sleeping,
        actual_accomplishment_intensity: 6,
        start_time: Time.local(2016, 1, 15, 23))

      expect(Activity.during(Time.local(2016, 1, 15, 21), Time.local(2016, 1, 15, 24)).completion_score).to eq(0)
    end
  end

  describe "create activity type" do
    let(:title) { "prancing in the woods" }

    it "creates an activity type when it has an activity type title" do
      Activity.create(
        participant: participants(:participant1),
        activity_type_title: title,
        start_time: Time.current
      )
      expect(participants(:participant1).activity_types.exists?(title: title)).to be true
    end

    it "doesn't create an activity type when it does not have an activity type title" do
      Activity.create(
        participant: participants(:participant1),
        start_time: Time.current
      )
      expect(participants(:participant1).activity_types.exists?(title: title)).to be false
    end
  end

  describe "updating an activity's actual attributes is possible after it has passed" do
    let(:activity) { activities(:planned_activity_today_1) }

    it ".actual_editable? returns true" do
      expect(activity.actual_editable?).to eq true
    end
  end

  describe "updating an activity's actual attributes is not possible while it is still in the future" do
    let(:activity) { activities(:planned_activity_today_4) }

    it "throws an error message when updating the actual_accomplishment_intensity" do
      activity.update(actual_accomplishment_intensity: 1)

      expect(activity.errors.full_messages).to include(
        "Actual accomplishment intensity can't be updated because activity is not in the past."
      )
    end

    it "throws an error message when updating the actual_pleasure_intensity" do
      activity.update(actual_pleasure_intensity: 1)

      expect(activity.errors.full_messages).to include(
        "Actual pleasure intensity can't be updated because activity is not in the past."
      )
    end

    it ".actual_editable? returns false" do
      expect(activity.actual_editable?).to eq false
    end
  end

  describe "updating an activity's actual attributes is not possible with an end_time of 'nil'" do
    let(:activity) { activities(:unplanned_activity1) }

    it ".actual_editable? returns false" do
      expect(activity.actual_editable?).to eq false
    end
  end

  describe "scopes" do
    it ".unplanned should only show activities where start_time and end_time are nil" do
      unplanned_activities = Activity.unplanned

      expect(unplanned_activities.load).not_to be_empty
      unplanned_activities.each do |a|
        expect(a.start_time).to be_nil
        expect(a.end_time).to be_nil
      end
    end

    it ".scheduled returns activities where is_scheduled is true" do
      scheduled_activities = Activity.scheduled

      expect(scheduled_activities.load).not_to be_empty
      scheduled_activities.each do |a|
        expect(a.is_scheduled).to eq true
      end
    end
  end

  describe "instance methods" do
    let(:activity1) { activities(:planned_activity_today_1) }
    let(:activity2) { activities(:planned_activity_today_2) }
    let(:activity3) { activities(:planned_activity_today_3) }

    it ".intensity_difference of accomplishment returns the difference of the predicted and actual" do
      expect(activity1.intensity_difference(:accomplishment)).to eq 5
    end

    it ".intensity_difference of pleasure returns the difference of the predicted and actual" do
      expect(activity1.intensity_difference(:pleasure)).to eq 0
    end

    it ".intensity_difference returns 'N/A' if no intensities are given" do
      expect(activity2.intensity_difference(:pleasure)).to eq "N/A"
    end

    it ".intensity_difference returns 'N/A' if no predictions are not given" do
      expect(activity3.intensity_difference(:pleasure)).to eq "N/A"
    end
  end
end
