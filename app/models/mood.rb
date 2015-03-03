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

  scope :last_seven_days, lambda {
    where(
      arel_table[:created_at]
        .gteq(Time.current.advance(days: -7).beginning_of_day))
  }

  scope :for_day, lambda { |time|
    where(
      arel_table[:created_at]
        .gteq(time.beginning_of_day)
        .and(arel_table[:created_at].lteq(time.end_of_day))
    )
  }
end
