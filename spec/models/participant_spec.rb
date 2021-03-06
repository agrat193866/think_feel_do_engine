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
  let(:participant_multiple_membership) { participants(:participant_multiple_membership) }

  describe "#notify_by_email?" do
    it "accurately describes if email should be the notification method" do
      expect(participant1.notify_by_email?).to eq true
      expect(participant2.notify_by_email?).to eq false
      expect(participant3.notify_by_email?).to eq false
    end
  end

  describe "#notify_by_sms?" do
    it "accurately describes if sms should be the notification method" do
      expect(participant1.notify_by_sms?).to eq false
      expect(participant2.notify_by_sms?).to eq true
      expect(participant3.notify_by_sms?).to eq true
    end
  end

  it "accurately populates and lists emotions" do
    expect(participant3.emotions.pluck("name")).not_to include("sad", "guilty", "calm", "concentrated", "relaxed")
    participant3.populate_emotions
    expect(participant3.emotions.pluck("name")).to include("sad", "guilty", "calm", "concentrated", "relaxed")
  end

  describe "#stepped" do
    it "returns participants that have been stepped" do
      count = Participant.stepped.count
      participant1.active_membership.update(stepped_on: Time.now)

      expect(Participant.stepped.count).to eq(count + 1)
    end
  end

  describe "#not_stepped" do
    it "returns participants that have not been stepped (i.e., one less now)" do
      count = Participant.not_stepped.count
      participant1.active_membership.update(stepped_on: Time.now)

      expect(Participant.not_stepped.count).to eq(count - 1)
    end
  end

  context "Active Participants" do
    describe "#stepped" do
      it "returns active participants that have been stepped" do
        participants = Participant.active.stepped

        expect(participants.empty?).to be_falsy
        participants.each do |p|
          expect(p.active_membership.stepped_on).to be_instance_of Date
        end
      end
    end

    describe "#not_stepped" do
      it "returns active participants that have not been stepped" do
        participants = Participant.active.not_stepped

        expect(participants.empty?).to be_falsy
        participants.each do |p|
          expect(p.active_membership.stepped_on).to be_nil
        end
      end
    end
  end

  context "Inactive Participants" do
    describe "#stepped" do
      it "returns inactive participants that have at least one membership which was stepped" do
        participants = Participant.inactive.stepped

        expect(participants.empty?).to be_falsy
        participants.each do |p|
          expect(p.active_membership).to be_nil
          expect(p.memberships.inactive.where("memberships.stepped_on IS NOT NULL").count).to be > 0
        end
      end
    end

    describe "#not_stepped" do
      it "returns inactive participants that have at least one membership which was not stepped" do
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
    end
  end

  describe "#is_not_allowed_in_site" do
    it "returns false if participants should be able to access site" do
      expect(participant_study_complete.is_not_allowed_in_site).to be_falsey
      expect(participant1.is_not_allowed_in_site).to be_falsey
    end

    it "returns true if participant has been withdrawn" do
      expect(inactive_participant2.is_not_allowed_in_site).to be_truthy
    end
  end

  describe "#active_group_is_social?" do
    it "returns true if participant is in a social group" do
      expect(participant1.active_group_is_social?).to be true
    end
  end

  describe "#most_recent_membership" do
    it "returns membership if a participant has more than one membership" do
      expect(participant_multiple_membership.most_recent_membership.end_date).to eq(Date.today)
    end

    it "returns membership if a participant has one membership" do
      expect(participant1.most_recent_membership).to be_instance_of Membership
    end
  end

  describe "#display_name" do
    it "returns participant display name if they have one" do
      expect(participant1.display_name).to eq "Aqua"
    end

    it "returns participant email (before the @) if they have no display name" do
      expect(participant3.display_name).to eq "participant3"
    end
  end

  context "A recent action exists for a participant" do
    let(:latest_action) do
      EventCapture::Event.create(
        emitted_at: Time.zone.now,
        participant_id: participant3.id
      )
    end

    before do
      latest_action.update(recorded_at: Time.zone.local(2020, 1, 1, 1, 1, 59))
    end

    describe "#duration_of_last_session" do
      it "returns the length of time between the current sign in and the most recent event" do
        participant3.update(current_sign_in_at: Time.zone.local(2020, 1, 1, 1, 1, 1))

        expect(participant3.duration_of_last_session).to eq 58
      end
    end

    describe "#latest_action_at" do
      it "returns the most recent event's recorded_at time" do
        expect(participant3.latest_action_at).to eq latest_action.recorded_at
      end
    end
  end

  context "When no events exist" do
    describe "#latest_action_at" do
      it "returns nil" do
        expect(participant3.latest_action_at).to be_nil
      end
    end
  end
end