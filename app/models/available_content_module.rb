# A read-only, view backed model that represents an assigned Content Module.
class AvailableContentModule < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :bit_core_tool
  belongs_to :participant
  has_many :content_providers,
           class_name: "BitCore::ContentProvider",
           foreign_key: :bit_core_content_module_id

  def self.for_participant(participant)
    where participant_id: participant.id
  end

  def self.for_tool(tool)
    where bit_core_tool_id: tool.id
  end

  def self.is_viz
    where is_viz: true
  end

  def self.is_not_viz
    where is_viz: false
  end

  def self.is_completed
    where.not completed_at: nil
  end

  def self.is_not_completed
    where completed_at: nil
  end

  def self.is_didactic
    where has_didactic_content: true
  end

  def self.is_not_didactic
    where has_didactic_content: false
  end

  def self.is_terminated_on(date)
    where(arel_table[:terminates_on].lt(date))
  end

  def self.is_not_terminated_on(date)
    where(arel_table[:terminates_on].eq(nil)
          .or(arel_table[:terminates_on].gteq(date)))
  end

  def self.available_by(date)
    where(arel_table[:available_on].lteq(date))
  end

  def self.available_on(date)
    where available_on: date
  end

  def self.excludes_module(content_module_or_id)
    where.not(id: content_module_or_id.try(:id) || content_module_or_id)
  end

  def self.order_by_position(direction = :asc)
    order position: direction
  end

  def self.position_greater_than(position)
    where(arel_table[:position].gt(position))
  end

  # Note that this scope must appear at the end of a chain. Its SQL doesn't
  # play nicely with Arel.
  def self.latest_duplicate
    select("
      DISTINCT ON (has_didactic_content,
                   bit_core_tool_id,
                   is_viz,
                   position,
                   title,
                   membership_id,
                   participant_id)
      *
    ")
      .order(:has_didactic_content,
             :bit_core_tool_id,
             :is_viz,
             :position,
             :title,
             :membership_id,
             :participant_id,
             available_on: :desc)
  end
end
