require "rails_helper"

feature "Learn", type: :feature do
  fixtures :all

  describe "When in learning" do
    describe "ContentProvider::LearnLessonsIndexProvider" do
      describe "When lesson availability is set to 0" do
        let(:participant1) { participants(:participant1) }

        before do
          Rails.application.config.lesson_week_length = 0
        end

        after do
          Rails.application.config.lesson_week_length = 16
        end

        scenario "No lessons are available for any weeks" do
          sign_in_participant participant1
          visit "/navigator/contexts/LEARN"

          within ".panel-group" do
            expect(page).not_to have_text "Week 1"
          end
        end
      end
    end
  end
end
