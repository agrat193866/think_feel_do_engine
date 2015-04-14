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
  validates :can_message_after_membership_complete, presence: true

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
    tools = Arel::Table.new(:bit_core_tools)
    bit_core_tools
      .where(tools[:type].eq(nil)
        .or(tools[:type].not_eq("Tools::Home"))
      )
  end
end
