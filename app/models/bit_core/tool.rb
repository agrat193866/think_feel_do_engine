require File.expand_path("../../app/models/bit_core/tool",
                         BitCore::Engine.called_from)

# Extend BitCore::Tool model.
module BitCore
  class Tool
    belongs_to :arm
    validates :arm_id, presence: true
  end
end
