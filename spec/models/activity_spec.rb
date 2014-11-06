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
end
