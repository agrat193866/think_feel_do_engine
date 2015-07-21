require "rails_helper"

describe Membership do
  fixtures :all

  let(:group) { groups(:group1) }
  let(:group_without_members1) { groups(:group_without_members1) }
  let(:group_without_members2) { groups(:group_without_members2) }
  let(:participant1) { participants(:participant1) }
  let(:participant_wo_membership1) { participants(:participant_wo_membership1) }
  let(:participant_wo_membership2) { participants(:participant_wo_membership2) }
  let(:lesson_task) { tasks(:task_learning7) }
  let(:membership1) { memberships(:membership1) }

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

    it "prevents is_complete=true and an end_date in the future" do
      expect(
        Membership.new(end_date: Date.today + 3.days, is_complete: true)
        .tap(&:valid?)
        .errors[:is_complete]
      ).not_to be_empty
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

    expect(participant_wo_membership1.active_membership.stepped_on).to eq nil
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

  describe "membership state modification" do
    let(:start_date) { Date.parse("2012-01-02") }
    let(:end_date) { Date.today }
    let(:participant1) { participants(:participant1) }
    let(:membership) do
      Membership.new(
        start_date: start_date,
        end_date: end_date,
        participant_id: participants(:participant1).id)
    end

    it "marks a membership as complete and dates back the end_date to yesterday" do
      expect(membership.is_complete).to eq false

      membership.flag_complete

      expect(membership.is_complete).to eq true
      expect(membership.end_date).to eq Date.yesterday
    end
  end

  describe "membership scopes" do
    let(:membership) { memberships(:membership1) }
    let(:participant_wo_membership3) { participants(:participant_wo_membership3) }
    let(:participant_wo_membership4) { participants(:participant_wo_membership4) }

    it ".active returns memberships that are completed" do
      count = Membership.active.count
      group.memberships.create(
        is_complete: true,
        start_date: Date.today.advance(days: -2),
        end_date: Date.today.advance(days: -1),
        participant: participant_wo_membership4)

      expect(Membership.active.count).to eq count + 1
    end

    it ".active returns memberships that are started before/on today and finishing today/in the future" do
      count = Membership.active.count
      group.memberships.create(
        start_date: Date.yesterday,
        end_date: Date.tomorrow,
        participant: participant_wo_membership1)
      group.memberships.create(
        start_date: Date.today.advance(days: -2),
        end_date: Date.today.advance(days: -1),
        participant: participant_wo_membership2)
      group.memberships.create(
        start_date: Date.today.advance(days: 1),
        end_date: Date.today.advance(days: 2),
        participant: participant_wo_membership3)

      expect(Membership.active.count).to eq count + 1
    end

    it ".inactive returns memberships that are started after today or finishing in the past" do
      count = Membership.inactive.count
      group.memberships.create(
        start_date: Date.today.advance(days: -2),
        end_date: Date.today.advance(days: -1),
        participant: participant_wo_membership1)
      group.memberships.create(
        start_date: Date.today.advance(days: 1),
        end_date: Date.today.advance(days: 2),
        participant: participant_wo_membership2)

      expect(Membership.inactive.count).to eq count + 2
    end

    it ".activities_future_by_week returns a count of activities "\
        " monitored for the first week" do
      expect(membership.logins_by_week(1)).to eq(2)
    end

    it ".continuing returns memberships where `is_complete` is false" do
      expect do
        memberships(:membership_participant_complete)
          .update(is_complete: false)
      end.to change { Membership.continuing.count }.by(1)
    end
  end

  describe "coach dashboard helper methods" do
    it ".lessons_read returns completed tasks that are lessons for a membership" do
      count = memberships(:membership1).lessons_read.count
      TaskStatus.create(
        membership_id: membership1.id,
        task_id: lesson_task.id,
        completed_at: Date.today
      )

      expect(membership1.lessons_read.count).to eq count + 1
    end

    it ".lessons_read_for_day(time) returns lessons completed on a given day" do
      count = memberships(:membership1).lessons_read_for_day(Date.today).count
      TaskStatus.create(
        membership_id: membership1.id,
        task_id: lesson_task.id,
        completed_at: Date.today
      )

      expect(membership1.lessons_read_for_day(Date.today).count).to eq count + 1
    end

    it ".lessons_read_for_week returns lessons completed in last seven days" do
      count = memberships(:membership1).lessons_read_for_week.count
      TaskStatus.create(
        membership_id: membership1.id,
        task_id: lesson_task.id,
        completed_at: (Date.today - 1.day)
      )
      TaskStatus.create(
        membership_id: membership1.id,
        task_id: lesson_task.id,
        completed_at: (Date.today - 8.days)
      )

      expect(membership1.lessons_read_for_week.count).to eq count + 1
    end
  end
end
