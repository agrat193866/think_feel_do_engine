require "csv"

module ThinkFeelDoEngine
  module Reports
    # Produces formatted versions of data produced by a data collector.
    # The collector is expected to have two methods:
    # `columns` returns a collection of column names
    # `all` returns a collection of Hashes whose keys match the column names
    class Reporter

      def self.fetch_reports
        return [] unless Rails.application.config.respond_to?(:reports)
        Rails.application.config.reports
      end
      
      def self.file_path(name)
        Rails.root.join("reports/#{name.to_s.gsub("_", "").downcase}.csv")
      end

      def initialize(collector)
        @collector = collector
        @path = self.class.file_path(parsed_name)
      end

      def write_csv
        CSV.open(@path, "wb") do |csv|
          to_csv(csv)
        end
      end

      def to_csv(csv=[])
        csv << @collector.columns
        @collector.all.each do |s|
          csv << @collector.columns.map { |c| s[c.to_sym] }
        end
      end
      
      private

      def parsed_name
        @collector.name.split("::").last.downcase
      end
    end
  end
end
