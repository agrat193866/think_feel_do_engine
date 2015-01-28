# Participants no longer rate their emotions, they rate emotional ratings
# These are objects tied to emotions - giving participants the opportunity
# to rate the same emotion multiple times.
class EmotionalRating < ActiveRecord::Base
  belongs_to :emotion
  belongs_to :participant

  validates :emotion, presence: true
  validates :participant, presence: true
  validates :rating, presence: true, inclusion: { in: 0..10 }

  attr_writer :name

  delegate :name, to: :emotion, prefix: false

  before_validation :associate_emotion

  scope :for_day, lambda { |datetime|
    where(
      arel_table[:created_at].gteq(datetime.beginning_of_day)
      .and(arel_table[:created_at].lteq(datetime.end_of_day))
    )
  }

  scope :positive, -> { where(arel_table[:is_positive].eq(true)) }

  scope :negative, -> { where(arel_table[:is_positive].eq(false)) }

  def rating_value
    Values::EmotionalRating.from_rating(rating).to_s
  end

  def self.attribute_names
    super.concat ["name"]
  end

  private

  def associate_emotion
    if @name.present?
      self.emotion = Emotion.associate(participant, @name)
    end
  end
end
