module Values
  # A value that might be assigned to an Activity.
  class Pleasure
    def self.from_intensity(intensity)
      return "Not answered" if intensity.nil?
      if intensity < 4
        new("Not Fun")
      elsif intensity < 7
        new("Kind of fun")
      else
        new("Really fun")
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
