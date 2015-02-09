# Log of participant viewings and listenings of media slides
class MediaAccessEvent < ActiveRecord::Base
  belongs_to :participant
  validates :media_type, inclusion: { in: ["audio", "video"] }
  validates :media_link, presence: :true
end
