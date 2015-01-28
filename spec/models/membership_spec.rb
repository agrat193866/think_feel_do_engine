require "spec_helper"

describe Membership do
  fixtures :all

  let(:group) { groups(:group1) }
  let(:group_without_members1) { groups(:group_without_members1) }
  let(:group_without_members2) { groups(:group_without_members2) }
  let(:participant1) { participants(:participant1) }
  let(:participant_wo_membership1) { participants(:participant_wo_membership1) }
  let(:participant_wo_membership2) { participants(:participant_wo_membership2) }

  describe "validations" do
    it "does not allow more than one active membership for a participant" do
      new_membership = Membership.new(
        group_id: group.id,
        participant_id: participants(:active_participant).id,
        start_date: Date.today,
        end_date: Date.tomorrow)
      expect(new_membership).not_to be_valid
    end

    it "allows valid memberships to be updated" do
      expect { memberships(:membership1).save! }.not_to raise_error
    end

    it "doesn't allow changing the group_id" do
      expect(memberships(:membership1).update(group: groups(:group2)))
        .to eq false
    end
  end

  it "assigns all tasks linked to a group upon creation" do
    task_ids = group_without_members1.tasks.map(&:id)
    expect(participant_wo_membership1.active_membership).to be_nil
    Membership.create!(
      participant_id: participant_wo_membership1.id,
      group_id: group_without_members1.id,
      start_date: Date.today,
      end_date: Date.today + 13.days)
    participant_wo_membership1.reload

    expect(participant_wo_membership1.active_membership.is_stepped).to eq false
    expect(participant_wo_membership1.active_membership.is_complete).to eq false

    new_task_ids = participant_wo_membership1
                   .reload
                   .active_membership.tasks.map(&:id)

    expect(new_task_ids).to eq task_ids
  end

  it "assigns all recurring tasks linked to a group upon creation" do
    task_ids = group_without_members2.tasks.map(&:id)

    expect(participant_wo_membership2.active_membership).to be_nil

    Membership.create!(
      participant_id: participant_wo_membership2.id,
      group_id: group_without_members2.id,
      start_date: Date.today,
      end_date: Date.today + 4.days)
    new_task_ids = participant_wo_membership2
                   .reload
                   .active_membership.tasks.map(&:id)

    expect(new_task_ids.uniq).to eq task_ids
    expect(new_task_ids.length).to eq 1
  end

  describe "date normalizations" do
    let(:start_date) { Date.parse("2012-01-02") }
    let(:end_date) { Date.parse("2013-02-03") }
    let(:membership) do
      Membership.new(start_date: start_date, end_date: end_date)
    end

    it "doesn't change ISO dates when an unrecognized format is passed" do
      membership.tap { |m| m.start_date_american = "12345" }.valid?
      expect(membership.start_date).to eq start_date
      membership.tap { |m| m.end_date_american = "2/3/4" }.valid?
      expect(membership.end_date).to eq end_date
    end

    it "parses 2-digit years correctly" do
      membership.tap { |m| m.start_date_american = "09/29/10" }.valid?
      expect(membership.start_date).to eq Date.parse("2010-09-29")
      membership.tap { |m| m.end_date_american = "12/5/00" }.valid?
      expect(membership.end_date).to eq Date.parse("2000-12-05")
    end

    it "parses 4-digit years correctly" do
      membership.tap { |m| m.start_date_american = "1/04/1999" }.valid?
      expect(membership.start_date).to eq Date.parse("1999-01-04")
      membership.tap { |m| m.end_date_american = "8/2/2014" }.valid?
      expect(membership.end_date).to eq Date.parse("2014-08-02")
    end
  end
end
