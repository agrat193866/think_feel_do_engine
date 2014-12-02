require File.expand_path("../../app/models/bit_core/tool",
                         BitCore::Engine.called_from)

# Extend BitCore::Tool model.
module BitCore
  class Tool
    belongs_to :arm
    validates :arm_id, presence: true

    validates :position,
              uniqueness: true,
              numericality: { greater_than_or_equal_to: 0 },
              uniqueness: { scope: :arm_id }
  end
end
