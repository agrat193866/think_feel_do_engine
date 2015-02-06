require "rails_helper"

describe Participant do
  fixtures(
    :users, :user_roles, :participants, :"bit_core/slideshows",
    :"bit_core/slides", :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships, :tasks, :task_status
  )

  let(:participant1) { participants(:participant1) }
  let(:participant2) { participants(:participant2) }
  let(:participant3) { participants(:participant3) }
  let(:participant_phq1) { participants(:participant_phq1) }
  let(:participant_phq2) { participants(:participant_phq2) }
  let(:participant_phq3) { participants(:participant_phq3) }
  let(:participant_phq4) { participants(:participant_phq4) }

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

  it ".active.stepped returns active participants that have been stepped" do
    participants = Participant.active.stepped

    expect(participants.empty?).to be_falsy
    participants.each do |p|
      expect(p.active_membership.is_stepped).to be_truthy
    end
  end

  it ".active.not_stepped returns active participants that have not been stepped" do
    participants = Participant.active.not_stepped

    expect(participants.empty?).to be_falsy
    participants.each do |p|
      expect(p.active_membership.is_stepped).to be_falsy
    end
  end

  it ".inactive.stepped returns inactive participants that have at least one membership which was stepped" do
    participants = Participant.inactive.stepped

    expect(participants.empty?).to be_falsy
    participants.each do |p|
      expect(p.active_membership).to be_nil
      expect(p.memberships.inactive.all.map(&:is_stepped).include?(true)).to be_truthy
    end
  end

  it ".inactive.not_stepped returns inactive participants that have at least one membership which was not stepped" do
    participants = Participant.inactive.not_stepped

    expect(participants.empty?).to be_falsy
    participants.each do |p|
      if p.active_membership
        expect(p.active_membership.is_complete == false)
      else
        expect(p.memberships.inactive.all.map(&:is_stepped).include?(false)).to be_truthy
      end
    end
  end
end
