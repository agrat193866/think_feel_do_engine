require "rails_helper"

describe ToolNavItem do
  fixtures :all

  describe "#alert" do
    def participant
      participants :participant1
    end

    context "the tool is not a subclass" do
      def tool
        bit_core_tools :thought_tracker
      end

      context "there are incomplete tasks" do
        it "returns 'New!'" do
          expect(ToolNavItem.new(participant, tool).alert).to eq "New!"
        end
      end

      context "there are no incomplete tasks" do
        it "returns nil" do
          TaskStatus.update_all completed_at: DateTime.now

          expect(ToolNavItem.new(participant, tool).alert).to be_nil
        end
      end
    end

    context "the tool is a subclass" do
      def tool
        bit_core_tools :library
      end

      context "there are > 0 incomplete tasks" do
        it "returns the task count" do
          expect(ToolNavItem.new(participant, tool).alert).to eq 1
        end
      end

      context "there are 0 incomplete tasks" do
        it "returns nil" do
          TaskStatus.update_all completed_at: DateTime.now

          expect(ToolNavItem.new(participant, tool).alert).to be_nil
        end
      end
    end

    context "Support tools exist" do
      let(:support) { bit_core_tools :support }
      let(:nav_item) { ToolNavItem.new(participant, support) }

      before do
        allow(nav_item).to receive(:any_incomplete_tasks_today?) { true }
      end

      it "returns nil - not 'New!'" do
        expect(nav_item.alert).to eq nil
      end
    end
  end

  describe "#display_alert" do
    context "Relax and Support tools exist" do
      let(:participant) { participants :participant1 }
      let(:tool) { bit_core_tools :thought_tracker }
      let(:relax) { bit_core_tools :relax }
      let(:support) { bit_core_tools :support }
      let(:nav) { ToolNavItem.new(participant, tool) }

      it "Verifies the alert doesn't display for the relax tool" do
        expect(nav.display_alert(relax)).to eq false
      end

      it "Verifies the alert doesn't display for the support tool" do
        expect(nav.display_alert(support)).to eq false
      end

      it "Verifies the alert shows for other tools" do
        expect(nav.display_alert(tool)).to eq true
      end
    end
  end

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

    it "doesn't return items that have terminated" do
      tasks(:task5_day1).update(termination_day: 1)
      Timecop.travel(today.advance(days: 2)) do
        terminated_items = tool_nav.module_nav_items
                           .where(Arel::Table.new(:available_content_modules)[
                                  :terminates_on].lt(Date.today))

        expect(terminated_items.to_a.count).to eq 0
      end
    end
  end
end
