require "rails_helper"

describe Participant do
  fixtures :all

  let(:participant1) { participants(:participant1) }
  let(:participant2) { participants(:participant2) }
  let(:participant3) { participants(:participant3) }
  let(:participant_phq1) { participants(:participant_phq1) }
  let(:participant_phq2) { participants(:participant_phq2) }
  let(:participant_phq3) { participants(:participant_phq3) }
  let(:participant_phq4) { participants(:participant_phq4) }
  let(:participant_study_complete) { participants(:participant_study_complete) }
  let(:inactive_participant2) { participants(:inactive_participant2) }

  it "accurately describes if email should be the notification method" do
    expect(participant1.notify_by_email?).to eq true
    expect(participant2.notify_by_email?).to eq false
    expect(participant3.notify_by_email?).to eq false
  end

  it "accurately describes if sms should be the notification method" do
    expect(participant1.notify_by_sms?).to eq false
    expect(participant2.notify_by_sms?).to eq true
    expect(participant3.notify_by_sms?).to eq true
  end

  it ".stepped returns participants that have been stepped" do
    count = Participant.stepped.count
    participant1.active_membership.update(stepped_on: Time.now)

    expect(Participant.stepped.count).to eq(count + 1)
  end

  it ".not_stepped returns participants that have not been stepped (i.e., one less now)" do
    count = Participant.not_stepped.count
    participant1.active_membership.update(stepped_on: Time.now)

    expect(Participant.not_stepped.count).to eq(count - 1)
  end

  it ".active.stepped returns active participants that have been stepped" do
    participants = Participant.active.stepped

    expect(participants.empty?).to be_falsy
    participants.each do |p|
      expect(p.active_membership.stepped_on).to be_instance_of Date
    end
  end

  it ".active.not_stepped returns active participants that have not been stepped" do
    participants = Participant.active.not_stepped

    expect(participants.empty?).to be_falsy
    participants.each do |p|
      expect(p.active_membership.stepped_on).to be_nil
    end
  end

  it ".inactive.stepped returns inactive participants that have at least one membership which was stepped" do
    participants = Participant.inactive.stepped

    expect(participants.empty?).to be_falsy
    participants.each do |p|
      expect(p.active_membership).to be_nil
      expect(p.memberships.inactive.where("memberships.stepped_on IS NOT NULL").count).to be > 0
    end
  end

  it ".inactive.not_stepped returns inactive participants that have at least one membership which was not stepped" do
    participants = Participant.inactive.not_stepped

    expect(participants.empty?).to be_falsy
    participants.each do |p|
      if p.active_membership
        expect(p.active_membership.is_complete == false)
      else
        expect(p.memberships.inactive.all.map(&:stepped_on).include?(nil)).to be_truthy
      end
    end
  end

  it ".is_not_allowed_in_site returns false if participants should be able to access site" do
    expect(participant_study_complete.is_not_allowed_in_site).to be_falsey
    expect(participant1.is_not_allowed_in_site).to be_falsey
  end

  it ".is_not_allowed_in_site returns true if participant has been withdrawn" do
    expect(inactive_participant2.is_not_allowed_in_site).to be_truthy
  end
end
