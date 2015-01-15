require "spec_helper"

feature "Feel", type: :feature do
  fixtures(
    :arms, :participants, :users, :groups, :memberships, :"bit_core/slideshows",
    :"bit_core/slides", :"bit_core/tools", :"bit_core/content_modules",
    :"bit_core/content_providers", :tasks, :task_status,
    :emotions, :emotional_ratings, :coach_assignments
  )

  context "Participant on day 1 logs in" do
    let(:participant1) { participants(:participant1) }
    let(:mood_and_emotions_provider_day1) { bit_core_content_providers(:mood_and_emotions_index_day1) }

    before :each do
      sign_in_participant participant1
      visit "/navigator/contexts/FEEL"
    end

    it "orders modules (i.e., task_statuses) in the correct order" do
      with_scope ".container .right.list-group" do
        expect(page.find("a.list-group-item.task-status:nth-child(1)")).to have_text "Tracking Your Mood"
        expect(page.find("a.list-group-item.task-status:nth-child(2)")).to have_text "Your Recent Moods & Emotions"
      end
    end

    it "Rates their Mood" do
      with_scope ".container .right.list-group" do
        click_on "Tracking Your Mood"
      end
      expect(page).to have_text("Rate your Mood")
      select("5 (Neither)", from: "mood[rating]")
      click_on "Continue"

      expect(page).to have_text("Mood saved")
      expect(current_path).to eq "/navigator/modules/" + mood_and_emotions_provider_day1.content_module.id.to_s + "/providers/" + mood_and_emotions_provider_day1.id.to_s + "/1"

      mood = Mood.find_by_participant_id(participant1.id)

      expect(mood).not_to be_nil
      expect(mood.rating).to eq 5
      expect(mood.rating_value).to eq "Neither"
    end
  end

  context "Participant on day 2 logs in" do
    let(:participant2) { participants(:participant2) }
    let(:mood_and_emotions_provider_post_day1) { bit_core_content_providers(:mood_and_emotions_index_post_day1) }

    before :each do
      sign_in_participant participant2
      visit "/navigator/contexts/FEEL"
    end

    it "orders modules (i.e., task_statuses) in the correct order" do
      with_scope ".container .right.list-group" do
        expect(page.find("a.list-group-item.task-status:nth-child(1)")).to have_text "Tracking Your Mood & Emotions"
        expect(page.find("a.list-group-item.task-status:nth-child(2)")).to have_text "Your Recent Moods & Emotions"
      end
    end

    it "allows participants to create and rate multiple emotions at once", :js do
      page.find(".container .right.list-group a.list-group-item.task-status:nth-child(1)").trigger("click")
      expect(page).to have_text "What is your mood right now?"
      select("5 (Neither)", from: "mood[rating]")
      click_on "Continue"
      select("surprised", from: "Emotion")
      select("5 (Some)", from: "emotional_rating[rating]")
      select("negative", from: "emotional_rating[is_positive]")

      page.find("#add-forms").trigger("click")

      with_scope "#subcontainer-1" do
        fill_in("Emotion", with: "Jubilant")
      end

      with_scope "#subcontainer-1" do
        select("3", from: "emotional_rating[rating]")
        select("positive", from: "emotional_rating[is_positive]")
      end

      page.find("#add-forms").trigger("click")

      with_scope "#subcontainer-2" do
        fill_in("Emotion", with: "Ecstatic")
      end

      with_scope "#subcontainer-2" do
        select("negative", from: "emotional_rating[is_positive]")
        select("7", from: "emotional_rating[rating]")
      end

      page.find("input.btn.btn-primary[value='Continue']").trigger("click")

      expect(page).to have_text("Emotional Rating saved")

      e = Emotion.where(name: "surprised").first

      expect(e).to_not be_nil

      rating = EmotionalRating.where(emotion_id: e.id, participant_id: participant2.id, rating: 5).first

      expect(rating.name).to eq "surprised"
      expect(rating.rating).to eq 5
      expect(rating.rating_value).to eq "Neither"

      e = Emotion.where(name: "jubilant").first

      expect(e).to_not be_nil

      rating = EmotionalRating.where(emotion_id: e.id, participant_id: participant2.id).first

      expect(rating.name).to eq "jubilant"
      expect(rating.rating).to eq 3
      expect(rating.rating_value).to eq "Bad"

      e = Emotion.where(name: "ecstatic").first

      expect(e).to_not be_nil

      rating = EmotionalRating.where(emotion_id: e.id, participant_id: participant2.id).first

      expect(rating.name).to eq "ecstatic"
      expect(rating.rating).to eq 7
      expect(rating.rating_value).to eq "Good"
      expect(page).to have_text "Mood"
      expect(page).to have_text "Positive and Negative Emotions"
    end
  end
end
