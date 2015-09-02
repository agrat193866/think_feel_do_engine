module ThinkFeelDoEngine
  # Used to present a presenter classes within a view.
  module PresentersHelper
    def present(object, klass)
      presenter = klass.new(object)
      yield presenter if block_given?
      presenter
    end
  end
end
