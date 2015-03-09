require "rails_helper"

module ThinkFeelDoEngine
  module Reports
    RSpec.describe Reporter do
      describe "#format_csv" do
        it "produces proper input for csv" do
          collector = double("collector",
                             name: "collector",
                             columns: %w( a b ),
                             all: [{ a: 1, b: 2 }, { a: "x", b: "y" }])

          expect(Reporter.new(collector).to_csv).to eq([{:a=>1, :b=>2}, {:a=>"x", :b=>"y"}])
        end
      end
    end
  end
end
