require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe Messaging do
      fixtures :all

      describe ".all" do
        let(:clinician1) { users(:clinician1) }
        let(:participant1) { participants(:participant1) }

        context "when there are no messages" do
          it "returns an empty array" do
            Message.destroy_all

            expect(Messaging.all).to be_empty
          end
        end

        context "when there is a message from Coach to Participant" do
          it "reports it" do
            Message.destroy_all
            m = Message.create!(sender: clinician1,
                                recipient: participant1,
                                subject: "Foo",
                                body: "Bar")

            report_line = Messaging.all.first

            expect(report_line[:message_id]).to eq m.id
            expect(report_line[:study_id]).to eq participant1.study_id
            expect(report_line[:therapist_id]).to eq clinician1.email
            expect(report_line[:sender_id]).to eq Messaging::COACH
            expect(report_line[:sender]).to eq clinician1.email
            expect(report_line[:recipient]).to eq participant1.study_id
            expect(report_line[:start_dt]).to eq participant1.active_membership.start_date
            expect(report_line[:treatment_week]).to eq 1
            expect(report_line[:day]).to eq 1
            expect(report_line[:event_date]).to eq m.sent_at.to_date.to_s(:db)
            expect(report_line[:event_time]).to eq m.sent_at.utc.iso8601
            expect(report_line[:is_message_opened]).to eq false
            expect(report_line[:message_opened_at]).to be_nil
            expect(report_line[:message_subject]).to eq "Foo"
            expect(report_line[:message_content]).to eq "Bar"
          end
        end

        context "when there is a message from Participant to Coach" do
          it "reports it" do
            Message.destroy_all
            m = Message.create!(sender: participant1,
                                recipient: clinician1,
                                subject: "Foo",
                                body: "Bar")

            report_line = Messaging.all.first

            expect(report_line[:message_id]).to eq m.id
            expect(report_line[:study_id]).to eq participant1.study_id
            expect(report_line[:therapist_id]).to eq clinician1.email
            expect(report_line[:sender_id]).to eq Messaging::PARTICIPANT
            expect(report_line[:sender]).to eq participant1.study_id
            expect(report_line[:recipient]).to eq clinician1.email
            expect(report_line[:start_dt]).to eq participant1.active_membership.start_date
            expect(report_line[:treatment_week]).to eq 1
            expect(report_line[:day]).to eq 1
            expect(report_line[:event_date]).to eq m.sent_at.to_date.to_s(:db)
            expect(report_line[:event_time]).to eq m.sent_at.utc.iso8601
            expect(report_line[:is_message_opened]).to eq false
            expect(report_line[:message_opened_at]).to be_nil
            expect(report_line[:message_subject]).to eq "Foo"
            expect(report_line[:message_content]).to eq "Bar"
          end
        end

        context "when there is not an active Membership" do
          it "reports nil start_dt, week and day values" do
            Message.destroy_all
            Membership.destroy_all
            Message.create!(sender: participant1,
                            recipient: clinician1,
                            subject: "Foo")

            report_line = Messaging.all.first

            expect(report_line[:start_dt]).to be_nil
            expect(report_line[:treatment_week]).to be_nil
            expect(report_line[:day]).to be_nil
          end
        end

        context "when the active Membership is older than the date sent" do
          it "reports the treatment week" do
            Message.destroy_all
            participant1.active_membership
              .update(start_date: Time.zone.now - 14.days)
            message = Message.create!(sender: participant1,
                                      recipient: clinician1,
                                      subject: "Foo")
            message.update(sent_at: Time.zone.now - 1.day)

            report_line = Messaging.all.first

            expect(report_line[:treatment_week]).to eq(2)
          end
        end

        context "when the Message has been opened" do
          it "reports it" do
            Message.destroy_all
            m = Message.create!(sender: participant1,
                                recipient: clinician1,
                                subject: "Foo")
            m.delivered_messages.first.update!(is_read: true)

            report_line = Messaging.all.first

            expect(report_line[:is_message_opened]).to eq true
            received_message = m.delivered_messages.first
            expect(report_line[:message_opened_at])
              .to eq received_message.updated_at.utc.iso8601
          end
        end
      end
    end
  end
end
