# The name given to an Activity. Can be private to a Participant or public.
class ActivityType < ActiveRecord::Base
  belongs_to :participant
  has_many :activities, dependent: :restrict_with_exception

  validates :title, presence: true
  # do not validate presence of participant
end
