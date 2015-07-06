require "rails_helper"

module ContentModules
  describe LessonModule do
    describe "render_current" do
      fixtures(:all)

      let(:markdown) { bit_core_content_modules(:lesson_with_markdown) }

      it "should have markdown free titles in the dashboard view" do
        expect(markdown.pretty_title).to match(/Lesson <strong>With<\/strong> Markdown/)
      end
    end
  end
end