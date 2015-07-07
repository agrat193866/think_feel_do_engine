require "rails_helper"

module ContentModules
  describe LessonModule do
    describe "#pretty_title" do
      fixtures(:all)

      let(:markdown) { bit_core_content_modules(:lesson_with_markdown) }

      it "returns a MarkDown-free string" do
        expect(markdown.pretty_title).to match(/Lesson <strong>With<\/strong> Markdown/)
      end
    end
  end
end