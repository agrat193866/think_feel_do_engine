module ThinkFeelDoEngine
  # Used to present a presenter classes within a view.
  module PresentersHelper
    def present(object, klass)
      yield klass.new(object)
    end
  end
end
