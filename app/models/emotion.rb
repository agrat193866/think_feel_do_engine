# Participants rate their emotions a name and intensity
class Emotion < ActiveRecord::Base
  belongs_to :creator, class_name: "Participant"
  has_many :emotional_ratings, dependent: :destroy

  validates :creator, presence: true
  validates :name, presence: true
  validates :name, uniqueness: { scope: :creator_id }

  before_validation :normalize_name

  def self.associate(participant, name)
    find_or_create_by(
      creator_id: participant.id,
      name: normalized_name(name)
    )
  end

  private

  def self.normalized_name(n)
    n.strip.downcase
  end

  def normalize_name
    if name.respond_to?(:strip)
      self.name = self.class.normalized_name(name)
    end
  end
end
