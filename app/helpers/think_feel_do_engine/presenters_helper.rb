module ThinkFeelDoEngine
  # Used to present a presenter classes within a view.
  module PresentersHelper
    def present(options, klass)
      yield klass.new(options)
    end
  end
end