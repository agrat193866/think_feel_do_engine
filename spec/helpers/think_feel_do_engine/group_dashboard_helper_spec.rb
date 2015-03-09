require "rails_helper"

module ThinkFeelDoEngine
  module Coach
    RSpec.describe GroupDashboardHelper, type: :helper do
      describe "#social_likes_and_comments_column_headers" do
        it "returns column headers if social features are active" do
          allow(helper).to receive(:social_features?) { true }
          expect(helper.social_likes_and_comments_column_headers).to eq("<th>Likes</th><th>Comments</th>")
        end
        it "returns nothing if social features are inactive" do
          allow(helper).to receive(:social_features?) { false }
          expect(helper.social_likes_and_comments_column_headers).to be_nil
        end
      end

      describe "#social_likes_and_comments_count_rows" do
        it "returns two social columns if social features are active" do
          allow(helper).to receive(:social_features?) { true }
          allow(helper).to receive(:like_count) { 5 }
          allow(helper).to receive(:comment_count) { 3 }
          expect(helper.social_likes_and_comments_count_rows(double("shared_item"))).to eq("<td>5</td><td>3</td>")
        end
        it "returns nothing if social features aren't active" do
          allow(helper).to receive(:social_features?) { false }
          expect(helper
                   .social_likes_and_comments_count_rows(
                     double("shared_item"))).to be_nil
        end
      end

      describe "#week_in_study" do
        it "should return the current week of a study" do
          membership = double("membership", start_date: Date.current - 25.days)
          expect(helper.week_in_study(Date.current, membership)).to eq(4)
        end
      end

      describe "#activity_status" do
        let(:activity) { double("activity") }

        it "should return monitored status when activity is monitored" do
          expect(activity).to receive(:monitored?) { true }
          expect(helper.activity_status(activity)).to eq("monitored")
        end

        it "should return planned status when activity is planned?" do
          expect(activity).to receive(:monitored?) { false }
          expect(activity).to receive(:planned?) { true }
          expect(helper.activity_status(activity)).to eq("planned")
        end
        it "should return (reviewed and complete) status when activity is reviewed and complete" do
          expect(activity).to receive(:monitored?) { false }
          expect(activity).to receive(:planned?) { false }
          expect(activity).to receive(:reviewed_and_complete?) { true }
          expect(helper.activity_status(activity)).to eq("reviewed and complete")
        end
        it "should return (reviewed and incomplete) status when activity is reviewed and incomplete" do
          expect(activity).to receive(:monitored?) { false }
          expect(activity).to receive(:planned?) { false }
          expect(activity).to receive(:reviewed_and_complete?) { false }
          expect(activity).to receive(:reviewed_and_incomplete?) { true }
          expect(helper.activity_status(activity)).to eq("reviewed and incomplete")
        end
      end

      describe "comment_item_description" do
        it "should return details for unknown shared items" do
          comment = double("comment", item_type: "Mood", item_id: 1)
          expect(helper.comment_item_description(comment))
            .to eq("Unknown Item Type, Item ID:1, Item Type: Mood")
        end

        it "should return a message when comment doesn't have associated item" do
          comment = double("comment", item_type: "SocialNetworking::SharedItem")
          expect(comment).to receive(:item) { nil }
          expect(helper.comment_item_description(comment))
            .to eq("Comment was made for an unknown item.")
        end
      end

      describe "aggregate lesson details related utilities" do
        fixtures(:all)
        let(:task1) { tasks(:task1) }

        it "#participants_that_read_lesson should return participant info" do
          expect(helper).to receive(:coach_group_patient_dashboard_path)
            .exactly(2) { "some link" }
          result = helper.participants_that_read_lesson(task1)
          expect(result).to include("completeParticipants-143279406")
          expect(result).to include("incompleteParticipants-143279406")
        end

        it "#list_participant_names displays a list for task1" do
          group = double("group", learning_tasks: [task1])
          expect(helper).to receive(:coach_group_patient_dashboard_path)
            .exactly(2) { "some link" }
          expect(helper.list_participant_names(group, task1.incomplete_participant_list)).to eq("<ul><li><a href=\"some link\">Aqua</a></li><li><a href=\"some link\">Water</a></li></ul>")
        end
      end

      describe "#goal_like_count" do
        let(:goal) { double("goal", id: 1) }
        let(:shared_item) { double("shared_items", id: 1000) }
        let(:shared_items) { [shared_item] }
        let(:countable) { double("countable", count: 1) }

        it "should return expected like count as a number" do
          expect(SocialNetworking::SharedItem).to receive(:where) { shared_items }
          expect(SocialNetworking::Like).to receive(:where) { countable }
          expect(helper.goal_like_count(goal)).to eq(1)
        end
      end
    end
  end
end
