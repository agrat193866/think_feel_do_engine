require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe Reporter do
      let(:collector) do
        double(
          name: "collector",
          columns: %w( a b ),
          all: [{ a: 1, b: 2 }, { a: "x", b: "y" }]
        )
      end
      let(:messy_collector) do
        double(
          name: "collector23%",
          columns: %w( a b ),
          all: [{ a: 1, b: 2 }, { a: "x", b: "y" }]
        )
      end

      describe "#format_csv" do
        it "produces proper input for csv" do
          expect(Reporter.new(collector).to_csv).to eq([{ a: 1, b: 2 }, { a: "x", b: "y" }])
        end
      end

      describe ".file_path" do
        it "generates the proper file path" do
          expect(Reporter.file_path(collector.name)).to eq(Rails.root.join("reports/collector.csv"))
        end

        it "sanitizes the file path to only include letters" do
          expect(Reporter.file_path(messy_collector.name)).to eq(Rails.root.join("reports/collector.csv"))
        end
      end
    end
  end
end
