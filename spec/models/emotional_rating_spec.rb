require "rails_helper"

describe EmotionalRating do
  fixtures :emotions, :emotional_ratings

  it ".for_day returns the emotional ratings for today" do
    ratings = EmotionalRating.for_day(Time.zone.now.advance(years: -1))

    expect(ratings.count).to eq 1
  end
end
