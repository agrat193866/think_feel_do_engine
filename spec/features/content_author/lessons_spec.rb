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

  let(:lessons_page) { LessonsPage.new(self) }

  before do
    sign_in_user users(:admin1)
    visit "/arms/#{arms(:arm1).id}/lessons"
  end

  scenario "creating" do
    new_lesson_page = lessons_page.select_new_lesson
    new_lesson_page.fill_in_title "Lesson Alpha"
    new_lesson_page.create_lesson

    expect(page).to have_text "Successfully created lesson"
  end

  scenario "adding a slide" do
    click_on "Home Introduction"
    click_on "Add Slide"
    fill_in "Title", with: "Slide Alpha"
    fill_in "Body", with: "Body A"
    click_on "Create"

    expect(page).to have_text("Successfully created slide for lesson")
  end

  scenario "adding a video slide" do
    click_on "Home Introduction"
    click_on "Add Video Slide"
    fill_in "Title", with: "Slide Beta"
    fill_in "Vimeo ID", with: "1234567"
    fill_in "Body", with: "Body B"
    click_on "Create"

    expect(page).to have_text("Successfully created slide for lesson")
  end

  scenario "deleting an assigned lesson" do
    lessons_page.delete_lesson "Do - Awareness Introduction"

    expect(page).to have_text "Lesson deleted."
  end
end
