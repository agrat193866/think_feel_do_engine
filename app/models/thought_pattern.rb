# A classification of a Thought.
class ThoughtPattern < ActiveRecord::Base
  has_many :thoughts, foreign_key: :pattern_id, dependent: :nullify

  validates :title, :description, :recommendations, presence: true
end
