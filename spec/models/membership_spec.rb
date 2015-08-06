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
    it "prohibits more than one active membership for a participant" do
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

    it "prohibits changing the group_id" do
      expect(memberships(:membership1).update(group: groups(:group2)))
        .to eq false
    end

    it "prohibits is_complete=true and an end_date in the future" do
      expect(
        Membership.new(end_date: Date.today + 3.days, is_complete: true)
        .tap(&:valid?)
        .errors[:is_complete]
      ).not_to be_empty
    end

    it "prohibits an end date to be set in the past" do
      expect(Membership.new(end_date: Date.yesterday).tap(&:valid?).errors[:end_date].length)
        .to be > 0
    end

    it "allows an end date in the past to exist" do
      existing_membership = Membership.first

      Timecop.travel existing_membership.end_date + 1.day do
        expect(existing_membership).to be_valid
      end
    end

    it "prohibits a nil end date to be created" do
      expect(Membership.new(end_date: nil).tap(&:valid?).errors[:end_date].length)
        .to be > 0
    end

    it "prohibits a nil end date to be updated" do
      expect(Membership.first.update(end_date: nil)).to eq false
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

  context "after creation" do
    it "assigns all recurring tasks linked to a group" do
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
  end

  describe "#withdraw" do
    it "sets the end_date in the past" do
      membership1.update!(end_date: Date.tomorrow)

      expect(membership1.withdraw).to be true
      expect(membership1.end_date).to be < Date.current
    end
  end

  describe "#discontinue" do
    it "sets the end_date in the past" do
      membership1.update!(end_date: Date.tomorrow)

      expect(membership1.discontinue).to be true
      expect(membership1.end_date).to be < Date.current
    end

    it "sets is_complete to true" do
      membership1.update!(is_complete: false)

      expect(membership1.discontinue).to be true
      expect(membership1.is_complete).to be true
    end
  end

  describe "#flag_complete" do
    it "marks a membership as complete and dates back the end_date to yesterday" do
      Membership.destroy_all
      incomplete_membership = Membership.create!(start_date: Date.yesterday,
                                                 end_date: Date.today,
                                                 group: group,
                                                 participant: participant1)
      expect(incomplete_membership.is_complete).to eq false

      expect(incomplete_membership.flag_complete).to eq true

      expect(incomplete_membership.is_complete).to eq true
      expect(incomplete_membership.end_date).to eq Date.yesterday
    end
  end

  describe "membership scopes" do
    let(:membership) { memberships(:membership1) }
    let(:participant_wo_membership3) { participants(:participant_wo_membership3) }
    let(:participant_wo_membership4) { participants(:participant_wo_membership4) }

    describe ".active" do
      it ".active returns memberships that are completed" do
        active_completed_membership = group.memberships.create(
          start_date: Date.current,
          end_date: Date.current + 1.day,
          participant: participant_wo_membership4)

        Timecop.travel Date.current + 2.days do
          active_completed_membership.update(is_complete: true)

          expect(Membership.active).to include active_completed_membership
        end
      end

      it "returns memberships that are started before/on today and finishing today/in the future" do
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
    end

    describe ".inactive" do
      it "returns memberships that are started after today or finishing in the past" do
        membership_in_the_past = group.memberships.create(
          start_date: Date.current,
          end_date: Date.current + 1.day,
          participant: participant_wo_membership1)
        membership_in_the_future = group.memberships.create(
          start_date: Date.current + 3.days,
          end_date: Date.current + 4.days,
          participant: participant_wo_membership2)

        Timecop.travel Date.current - 2.days do
          inactive_memberships = Membership.inactive
          expect(inactive_memberships).to include membership_in_the_past
          expect(inactive_memberships).to include membership_in_the_future
        end
      end
    end

    describe ".activities_future_by_week" do
      it "returns a count of activities monitored for the first week" do
        expect(membership.logins_by_week(1)).to eq(2)
      end
    end

    describe ".continuing" do
      it "returns memberships where `is_complete` is false" do
        expect do
          memberships(:membership_participant_complete)
            .update(is_complete: false)
        end.to change { Membership.continuing.count }.by(1)
      end
    end
  end

  describe "coach dashboard helper methods" do
    describe ".lessons_read" do
      it "returns completed tasks that are lessons for a membership" do
        count = memberships(:membership1).lessons_read.count
        TaskStatus.create(
          membership_id: membership1.id,
          task_id: lesson_task.id,
          completed_at: Date.today
        )

        expect(membership1.lessons_read.count).to eq count + 1
      end
    end

    describe ".lessons_read_for_day" do
      it "returns lessons completed on a given day" do
        count = memberships(:membership1).lessons_read_for_day(Date.today).count
        TaskStatus.create(
          membership_id: membership1.id,
          task_id: lesson_task.id,
          completed_at: Date.today
        )

        expect(membership1.lessons_read_for_day(Date.today).count).to eq count + 1
      end
    end

    describe ".lessons_read_for_week" do
      it "returns lessons completed in last seven days" do
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
end
