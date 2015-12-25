require "rails_helper"

module ContentModules
  describe LessonModule, type: :model do
    fixtures :all

    describe "#pretty_title" do
      let(:markdown) { bit_core_content_modules(:lesson_with_markdown) }

      it "returns a MarkDown-free string" do
        expect(markdown.pretty_title).to match(/Lesson <strong>With<\/strong> Markdown/)
      end
    end

    describe "when slides exist" do
      let(:learning_slideshow) { bit_core_slideshows(:learn_thoughts_intro) }

      before do
        learning_slideshow.slides.create!(body: "", position: 1, title: "Slide 1")
        learning_slideshow.slides.create!(body: "", position: 2, title: "Slide 2")
        learning_slideshow.slides.create!(body: "", position: 3, title: "Slide 3")
      end

      describe "#destroy_slide" do
        describe "when deleting a slide that is positioned at least 3rd from last" do
          let(:slide) { learning_slideshow.slides.find_by_title("Slide 1") }

          it "deletes the slide" do
            expect do
              bit_core_content_modules(:slideshow_content_module_16)
                .destroy_slide(slide)
            end.to change { BitCore::Slide.count }.by(-1)
          end
        end
      end
    end
  end
end
