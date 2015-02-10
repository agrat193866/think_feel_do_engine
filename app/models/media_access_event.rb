# Log of participant viewings and listenings of media slides
class MediaAccessEvent < ActiveRecord::Base
  belongs_to :participant,
             foreign_key: :participant_id
  belongs_to :slide,
             class_name: "BitCore::Slide",
             foreign_key: :bit_core_slide_id
  validates :media_type, inclusion: { in: ["audio", "video"] }
  validates :media_link,
            :participant_id,
            :bit_core_slide_id,
            presence: :true
end
