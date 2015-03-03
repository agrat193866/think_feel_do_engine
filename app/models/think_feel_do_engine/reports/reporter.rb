require "csv"

module ThinkFeelDoEngine
  module Reports
    # Produces formatted versions of data produced by a data collector.
    # The collector is expected to have two methods:
    # `columns` returns a collection of column names
    # `all` returns a collection of Hashes whose keys match the column names
    class Reporter
      def initialize(collector)
        @collector = collector
      end

      def to_csv
        CSV.generate do |csv|
          csv << @collector.columns
          @collector.all.each do |s|
            csv << @collector.columns.map { |c| s[c.to_sym] }
          end
        end
      end
    end
  end
end
