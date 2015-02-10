require "rails_helper"

describe Mood do
  fixtures :participants

  let(:participant) { participants(:participant1) }

  it ".for_day returns moods for a particular day" do
    count = Mood.for_day(Time.current).count

    Mood.create(
      created_at: Time.current.beginning_of_day.advance(seconds: -1),
      participant: participant,
      rating: 1)

    Mood.create(
      created_at: Time.current.beginning_of_day,
      participant: participant,
      rating: 1)

    Mood.create(
      created_at: Time.current.end_of_day,
      participant: participant,
      rating: 1)

    Mood.create(
      created_at: Time.current.end_of_day.advance(seconds: 1),
      participant: participant,
      rating: 1)

    expect(Mood.for_day(Time.current).count).to eq(count + 2)
  end
end