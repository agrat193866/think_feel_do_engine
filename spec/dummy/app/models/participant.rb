require File.expand_path("../../app/models/participant",
                         ThinkFeelDoEngine::Engine.called_from)

# Extend Participant model.
class Participant
   def phq_scores
    ratings = []
    phq_assessments.each do |phq|
      ratings << { day: phq.release_date,
                   intensity: phq.score,
                   drill_down: false
                 }
    end
    ratings
  end
end
