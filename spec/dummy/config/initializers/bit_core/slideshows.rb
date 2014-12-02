require File.expand_path("../../app/models/bit_core/slideshow",
                         BitCore::Engine.called_from)

# Extend BitCore::Slideshow model.
module BitCore
  class Slideshow
    belongs_to :arm
    validates :arm_id, presence: true
  end
end
