require "spec_helper"

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
  fixtures(
    :arms, :users, :user_roles, :"bit_core/slideshows", :"bit_core/slides",
    :"bit_core/tools", :"bit_core/content_modules", :groups,
    :"bit_core/content_providers", :tasks
  )

  context "Logged in as a content author" do
    let(:lessons_page) { LessonsPage.new(self) }

    before do
      sign_in_user users(:content_author1)
    end

    scenario "should see arm links" do
      visit "/arms"

      expect(page).to_not have_link "Researcher Dashboard"
      expect(page).to_not have_link "Coach Dashboard"
      expect(page).to have_link "Arm 1"
      expect(page).to have_link "Arm 2"
    end

    scenario "should see arm links" do
      visit "/arms"
      click_on "Arm 1"

      expect(page).to have_link "Manage Content"
    end

    scenario "should only see lessons related to an arm" do
      visit "/arms/#{arms(:arm1).id}/lessons"

      expect(page).to have_text "Home Introduction"
      expect(page).to_not have_text "HELLO aligator"

      visit "/arms/#{arms(:arm2).id}/lessons"

      expect(page).to have_text "HELLO aligator"    
      expect(page).to_not have_text "Home Introduction"
    end

    scenario "creating" do
      visit "/arms/#{arms(:arm1).id}/lessons"
      new_lesson_page = lessons_page.select_new_lesson
      new_lesson_page.fill_in_title "Lesson Alpha"
      new_lesson_page.create_lesson

      expect(page).to have_text "Successfully created lesson"
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

    scenario "deleting an assigned lesson" do
      visit "/arms/#{arms(:arm1).id}/lessons"
      lessons_page.delete_lesson "Do - Awareness Introduction"

      expect(page).to have_text "Lesson deleted."
    end
  end
end
