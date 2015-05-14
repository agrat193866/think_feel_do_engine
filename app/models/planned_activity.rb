# A planned activity is expected to take place in the future.
class PlannedActivity < Activity
  validates :predicted_accomplishment_intensity, :predicted_pleasure_intensity,
            presence: true
end
