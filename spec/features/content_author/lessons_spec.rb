require "rails_helper"

class LessonsPage
  def initialize(context)
    @context = context
    @path = "/lessons"
  end

  def visit
    @context.visit @path
  end

  def select_new_lesson
    @context.click_on "New"

    NewLessonPage.new(@context)
  end

  def delete_lesson(lesson_title)
    lesson_id = ContentModules::LessonModule.find_by_title(lesson_title).id
    @context.within(:xpath, "//tr[@id='lesson-#{ lesson_id }']") do
      @context.click_on "Delete"
    end
  end
end

class NewLessonPage
  def initialize(context)
    @context = context
  end

  def fill_in_title(text)
    @context.fill_in "Title", with: text
  end

  def create_lesson
    @context.click_on "Create"
  end
end

feature "Lessons", type: :feature do
  fixtures :all

  context "Logged in as a content author" do
    let(:lessons_page) { LessonsPage.new(self) }

    before do
      sign_in_user users(:content_author1)
    end

    scenario "should only see lessons related to an arm" do
      visit "/arms/#{arms(:arm1).id}/lessons"

      expect(page).to have_text "Home Introduction"
      expect(page).to_not have_text "HELLO aligator"

      visit "/arms/#{arms(:arm2).id}/lessons"

      expect(page).to have_text "HELLO aligator"
      expect(page).to_not have_text "Home Introduction"
    end

    scenario "viewing all lesson slides" do
      visit "/arms/#{ arms(:arm1).id }/lessons/all_content"

      expect(page).to have_text bit_core_slideshows(:think_patterns_intro).title
      expect(page).to have_text bit_core_slides(:think_patterns_intro1).title
      expect(page).to have_text bit_core_slides(:think_patterns_intro1)
        .render_body[/[^<>]+/]
      expect(page).to have_text bit_core_slides(:think_reshape_intro).title
      expect(page).to have_text bit_core_slides(:think_reshape_intro)
        .render_body[/[^<>]+/]
    end

    scenario "viewing video slides" do
      lesson = bit_core_content_modules(:slideshow_content_module_13)
      slide = bit_core_slides(:feel_emotions_intro1)
      visit "/arms/#{ arms(:arm1).id }/lessons/#{ lesson.id }/" \
            "lesson_slides/#{ slide.id }"
    end

    scenario "creating" do
      visit "/arms/#{arms(:arm1).id}/lessons"
      new_lesson_page = lessons_page.select_new_lesson
      new_lesson_page.fill_in_title "Lesson Alpha"
      new_lesson_page.create_lesson

      expect(page).to have_text "Successfully created lesson"

      click_on "Add Slide"
      fill_in "Title", with: "title"
      fill_in "Body", with: "body"
      click_on "Create"

      expect(page).to have_text "Successfully created slide"
    end

    scenario "create a lesson for an arm when no lessons yet exist" do
      arm_lessons = BitCore::ContentModule.where(bit_core_tool_id: arms(:arm3).bit_core_tools.map(&:id))

      expect(arm_lessons.count).to eq 0

      visit "/arms/#{arms(:arm3).id}/lessons"
      click_on "New"
      fill_in "Title", with: "Lesson Alpha"
      fill_in "Position", with: 1
      click_on "Create"

      expect(page).to have_text "Successfully created lesson"
    end

    scenario "adding a slide" do
      visit "/arms/#{arms(:arm1).id}/lessons"
      click_on "Home Introduction"
      click_on "Add Slide"
      fill_in "Title", with: "Slide Alpha"
      fill_in "Body", with: "Body A"
      click_on "Create"

      expect(page).to have_text("Successfully created slide for lesson")
    end

    scenario "adding a video slide" do
      visit "/arms/#{arms(:arm1).id}/lessons"
      click_on "Home Introduction"
      click_on "Add Video Slide"
      fill_in "Title", with: "Slide Beta"
      fill_in "Vimeo ID", with: "1234567"
      fill_in "Body", with: "Body B"
      click_on "Create"

      expect(page).to have_text("Successfully created slide for lesson")
    end

    scenario "adding an audio slide" do
      visit "/arms/#{arms(:arm1).id}/lessons"
      click_on "Home Introduction"
      click_on "Add Audio Slide"
      fill_in "Title", with: "Slide Beta"
      fill_in "Audio URL", with: "1234567"
      fill_in "Body", with: "Body B"
      click_on "Create"

      expect(page).to have_text("Successfully created slide for lesson")
    end

    scenario "deleting an assigned lesson" do
      visit "/arms/#{arms(:arm1).id}/lessons"
      lessons_page.delete_lesson "Do - Awareness Introduction"

      expect(page).to have_text "Lesson deleted."
    end
  end
end
