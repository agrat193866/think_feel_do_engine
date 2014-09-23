# Participants rate their mood
class Mood < ActiveRecord::Base
  belongs_to :participant
  validates :participant, presence: true
  validates :rating, presence: true, inclusion: { in: 0..10 }

  def rating_value
    Values::Mood.from_rating(rating).to_s
  end
end
