# A collection of Activities that have not been scheduled by a Participant.
class UnplannedActivities
  Errors = Struct.new(:full_messages)

  attr_reader :errors

  def self.attribute_names
    []
  end

  def initialize(participant)
    @participant = participant
    @activities = []
  end

  def build(attributes)
    many_attributes = case
                      when attributes[:activity_type_ids]
                        (attributes[:activity_type_ids] || []).map do |type_id|
                          { activity_type_id: type_id }
                        end
                      else
                        attributes.values
                      end
    build_many(many_attributes)

    self
  end

  def save
    Activity.transaction { @activities.each(&:save!) }

    true
  rescue => err
    @errors = Errors.new(Array(err.to_s))

    false
  end

  private

  def build_many(arr_of_attributes)
    arr_of_attributes.each do |attrs|
      @activities << @participant.build_data_record(:activities, attrs)
    end
  end
end
