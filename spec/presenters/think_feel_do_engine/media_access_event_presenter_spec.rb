require "rails_helper"

module ThinkFeelDoEngine
  RSpec.describe MediaAccessEventPresenter do
    let(:event) do
      instance_double(
        MediaAccessEvent,
        created_at: Time.zone.now,
        end_time: Time.zone.now + 1.hour,
        slide_title: "foo",
        task_release_day: 3)
    end

    def media_access_event
      MediaAccessEventPresenter.new(event: event, start_date: Date.today)
    end

    describe "#completed" do
      it "returns truthy if ending time is present" do
        expect(media_access_event.completed)
          .to be_truthy
      end

      it "returns falsey if ending time is not present" do
        event = instance_double(MediaAccessEvent, end_time: nil)

        expect(MediaAccessEventPresenter.new(event: event, start_date: Date.today).completed)
          .to be_falsey
      end
    end

    describe "#available_on" do
      it "returns the date of availability" do
        expect(media_access_event.available_on)
          .to eq((Date.today + 2.days).to_s(:user_date))
      end
    end

    describe "#duration_of_session" do
      it "returns the length of the event" do
        expect(media_access_event.duration_of_session)
          .to be_within(0.1).of(3600)
      end
    end

    describe "#sortable" do
      it "returns the number of seconds since the event was started" do
        event = instance_double(MediaAccessEvent, task_release_day: 2)

        expect(MediaAccessEventPresenter.new(event: event, start_date: Date.today).sortable)
          .to eq Date.parse("2015-01-22").to_time.to_i
      end
    end

    describe "#title" do
      it "returns slide's title" do
        expect(media_access_event.title)
          .to eq "foo"
      end
    end
  end
end
