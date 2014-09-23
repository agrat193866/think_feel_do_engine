module Values
  # Participants rate their emotion with an intensity
  class EmotionalRating
    def self.from_rating(rating)
      return "Not answered" if rating.nil?
      if rating < 5
        new("Bad")
      elsif rating == 5
        new("Neither")
      else
        new("Good")
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