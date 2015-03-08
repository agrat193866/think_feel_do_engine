# A read-only, view backed model that represents an assigned Content Module.
class AvailableContentModule < ActiveRecord::Base
  belongs_to :bit_core_tool
  belongs_to :participant
end
