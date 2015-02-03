require "spec_helper"

describe Activity do
  fixtures [:participants, :activity_types, :activities]

  describe "create activity type" do
    let(:title) { "prancing in the woods" }

    it "creates an activity type when it has an activity type title" do
      Activity.create(
        participant: participants(:participant1),
        activity_type_title: title,
        start_time: Time.current,
        end_time: Time.current + 1.hour
      )
      expect(participants(:participant1).activity_types.exists?(title: title)).to be true
    end

    it "doesn't create an activity type when it does not have an activity type title" do
      Activity.create(
        participant: participants(:participant1),
        start_time: Time.current,
        end_time: Time.current + 1.hour
      )
      expect(participants(:participant1).activity_types.exists?(title: title)).to be false
    end
  end

  describe "updating an activity's actual attributes is possible after it has passed" do
    let(:activity) { activities(:planned_activity_today_1) }

    it ".actual_editable? returns true" do
      expect(activity.actual_editable?).to be_truthy
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
      expect(activity.actual_editable?).to be_falsy
    end
  end

  describe "updating an activity's actual attributes is not possible with an end_time of 'nil'" do
    let(:activity) { activities(:unplanned_activity1) }

    it ".actual_editable? returns false" do
      expect(activity.actual_editable?).to be_falsy
      expect(activity.actual_editable?).to be_nil
    end
  end

  describe "scopes" do
    it "unplanned should only show activities where start_time and end_time are nil" do
      unplanned_activities = Activity.unplanned
      expect(unplanned_activities.load).not_to be_empty
      unplanned_activities.each do |a|
        expect(a.start_time).to be_nil
        expect(a.end_time).to be_nil
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
