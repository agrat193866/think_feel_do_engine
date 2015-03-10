require "rails_helper"

describe ToolNavItem do
  fixtures :all

  describe "#is_active?" do
    def tool
      double("tool", id: 1)
    end

    def nav_item
      ToolNavItem.new("participant", tool)
    end

    it "returns true if the current module is in the tool" do
      tool_module = double("tool module", bit_core_tool_id: 1)

      expect(nav_item.is_active?(tool_module)).to eq true
    end

    it "returns false if the current module is not in the tool" do
      tool_module = double("tool module", bit_core_tool_id: 1000)
      expect(nav_item.is_active?(tool_module)).to eq false
    end
  end

  describe "#module_nav_items" do
    def today
      Date.current
    end

    def tool_nav(participant = :participant1)
      ToolNavItem.new(participants(participant),
                      bit_core_tools(:thought_tracker))
    end

    it "returns items assigned before today" do
      Timecop.travel(today.advance(days: 1)) do
        earlier_items = tool_nav.module_nav_items
                        .where(Arel::Table.new(:available_content_modules)[
                               :available_on].lt(today))

        expect(earlier_items.to_a.count).to be > 0
        earlier_items.each { |item| expect(item.available_on).to be < today }
      end
    end

    it "returns items assigned today" do
      today_items = tool_nav.module_nav_items.where(available_on: today)

      expect(today_items.to_a.count).to be > 0
    end

    it "doesn't return items assigned after today" do
      later_items = tool_nav.module_nav_items
                    .where(Arel::Table.new(:available_content_modules)[
                           :available_on].gt(today))

      expect(later_items.to_a.count).to eq 0
    end

    it "doesn't return duplicate items" do
      titles = tool_nav(:participant2).module_nav_items.map(&:title)

      expect(titles.count).to eq titles.uniq.count
    end
  end
end
