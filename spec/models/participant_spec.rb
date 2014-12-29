require "spec_helper"

describe Participant do
  fixtures(
    :users, :user_roles, :participants, :"bit_core/slideshows",
    :"bit_core/slides", :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :groups, :memberships, :tasks, :task_status
  )

  let(:participant1) { participants(:participant1) }
  let(:participant2) { participants(:participant2) }
  let(:participant3) { participants(:participant3) }

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
end
