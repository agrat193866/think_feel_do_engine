# Log of participant viewings and listenings of media slides
class MediaAccessEvent < ActiveRecord::Base
  belongs_to :participant,
             foreign_key: :participant_id
  belongs_to :slide,
             class_name: "BitCore::Slide",
             foreign_key: :bit_core_slide_id
  validates :media_type, inclusion: { in: ["audio", "video"] }
  validates :media_link,
            :participant,
            :slide,
            presence: :true

  def task_release_day
    module_id = slide.slideshow.content_provider.bit_core_content_module_id

    Task.where(
      bit_core_content_module_id: module_id,
      group_id: participant.active_group.id
    ).first.release_day
  end
end
