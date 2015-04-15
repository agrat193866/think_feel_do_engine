# Validates Arm model.
class ArmValidator < ActiveModel::Validator
  def validate(record)
    if ActiveRecord::Base.connection.column_exists?(:arms, :can_message_after_membership_complete) &&
       !record.can_message_after_membership_complete
      record.errors[:base] << "An Arm must have a value for can_message"\
                              "_after_membership_complete"
    end
  end
end
