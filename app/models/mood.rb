# Participants rate their mood
class Mood < ActiveRecord::Base
  belongs_to :participant
  validates :participant, presence: true
  validates :rating, presence: true, inclusion: { in: 0..10 }

  scope :for_day, lambda { |datetime|
    where(
      arel_table[:created_at].gteq(datetime.beginning_of_day)
      .and(arel_table[:created_at].lteq(datetime.end_of_day))
    )
  }

  def rating_value
    Values::Mood.from_rating(rating).to_s
  end
end
