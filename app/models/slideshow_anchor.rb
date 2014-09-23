# Defines a relationship between a BitCore::Slideshow and a "target", which for
# now is limited to the home screen of a Participant.
class SlideshowAnchor < ActiveRecord::Base
  TARGET_NAMES = %w(home_intro)

  belongs_to :slideshow,
             class_name: "BitCore::Slideshow",
             foreign_key: :bit_core_slideshow_id

  validates :slideshow, :target_name, presence: true
  validates :target_name, inclusion: { in: TARGET_NAMES }, uniqueness: true

  def self.fetch(target_name)
    find_by_target_name(target_name.to_s).try(:slideshow)
  end
end
