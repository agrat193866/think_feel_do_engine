require "rails_helper"

describe Arm do
  fixtures :all

  let(:arm) { arms(:arm5) }

  it ".non_home_tools returns tool types that are nil or not Tools::Home" do
    expect(arm.non_home_tools.count).to eq 0

    BitCore::Tool.create(
      position: 1,
      title: "nullish",
      arm: arm)
    BitCore::Tool.create(
      position: 2,
      title: "Is Not Tools Home",
      arm: arm,
      type: "Tools::Messages")

    expect(arm.non_home_tools.count).to eq 2
  end
end