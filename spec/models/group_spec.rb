require "spec_helper"

describe Group do
  fixtures :all

  describe "creation of moderator" do

    context "Social Arms" do
      let(:social_arm) { arms(:arm1) }
      let(:group) { social_arm.groups.create!(title: "Group with moderator") }

      it "creates a moderator" do
        expect(group.moderator).to_not be_nil
        expect(group.moderator.is_admin).to eq true
      end

      it "validates whether a moderator exists for groups of social arms" do
        moderator = group.moderator
        moderator.update_attributes(is_admin: false)
        moderator.reload

        expect(moderator).to_not be_nil
        expect(moderator.is_admin).to eq true
        expect(moderator.errors.full_messages.include?("at least one moderator needs to exist.")).to eq true
      end
    end

    context "Non-Social Arms" do
      let(:non_social_arm) { arms(:arm2) }
      let(:non_social_group) { Group.create!(arm_id: non_social_arm.id, title: "Group without moderator") }

      it "doesn't assign a moderator upon creation for non-social arms" do
        expect(non_social_group.moderator).to be_nil
      end

      it "doesn't allow a moderator to become a member of a group in a non-social arm" do
        membership = non_social_group.memberships.create(
          participant_id: participants(:moderator_for_group1).id,
          start_date: Date.today,
          end_date: Date.today.advance(weeks: 8)
        )

        expect(membership.errors.full_messages.include?("moderators can't be part of this group.")).to eq true
      end
    end
  end
end
