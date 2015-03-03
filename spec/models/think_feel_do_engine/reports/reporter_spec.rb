require "spec_helper"
require_relative "../../../../app/models/think_feel_do_engine/reports/reporter"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe Reporter do
      describe "#to_csv" do
        it "produces csv from proper input" do
          collector = double("collector",
                             columns: %w( a b ),
                             all: [{ a: 1, b: 2 }, { a: "x", b: "y" }])

          expect(Reporter.new(collector).to_csv).to eq("a,b\n1,2\nx,y\n")
        end
      end
    end
  end
end
