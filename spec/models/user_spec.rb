require "rails_helper"

describe User do
  fixtures :all

  let(:group) { groups(:group1) }
  let(:clinician) { users(:clinician1) }

  it ".participants_for_group returns the assigned participants within a group" do
    expect(clinician.participants_for_group(group)).to include participants(:participant1)
    expect(clinician.participants_for_group(group)).not_to include participants(:participant2)
  end
end
