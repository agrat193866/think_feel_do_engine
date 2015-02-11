# These arms are part of the adolescent and adult projects
# Between 1 and 8 groups are in each arm and each group
# could have between 1 and 10 or so participants
class Arm < ActiveRecord::Base
  has_many :groups, dependent: :nullify
  has_many :bit_core_tools,
           class_name: "BitCore::Tool",
           foreign_key: :arm_id,
           dependent: :destroy
  has_many :bit_core_slideshows,
           class_name: "BitCore::Slideshow",
           foreign_key: :arm_id,
           dependent: :destroy

  validates :title, presence: true

  def display_name_required_for_membership?(participant, display_name)
    if social? && display_name.empty?
      participant.errors.add(
        :display_name, "is required because the arm of this \
          intervention utilizes social features or the \
          participant is currently enrolled in an arm that \
          requires a display name."
        )
      false
    else
      true
    end
  end

  def social?
    is_social
  end

  def woz?
    has_woz
  end

  def non_home_tools
    bit_core_tools.where("bit_core_tools.type IS NULL OR " \
                         "bit_core_tools.type != 'Tools::Home'")
  end
end
