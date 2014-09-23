module Values
  # A value that might be assigned to an Activity.
  class Accomplishment
    def self.from_intensity(intensity)
      return "Not answered" if intensity.nil?
      if intensity < 4
        new("Low Importance")
      elsif intensity < 7
        new("Average Importance")
      else
        new("High Importance")
      end
    end

    def initialize(label)
      @label = label
    end

    def to_s
      @label.to_s
    end
  end
end