require "rails_helper"

module SocialNetworking
  RSpec.describe "think_feel_do_engine/coach/group_dashboard/_goals.html.erb",
                 type: :view do
    let(:goal) do
      instance_double(
        Goal,
        completed_at: nil,
        created_at: Time.zone.now,
        deleted_at: nil,
        description: "foo",
        due_on: nil,
        comments: [])
    end
    let(:membership) do
      instance_double(
        Membership,
        start_date: Time.zone.now)
    end
    let(:partial) { "think_feel_do_engine/coach/group_dashboard/goals" }

    describe "A goal exists" do
      before do
        allow(membership).to receive_message_chain("participant.display_name") { "bar" }
        allow(view).to receive_message_chain("group.memberships") { [membership] }
        allow(view).to receive(:membership_goals) { [goal] }
        allow(view).to receive(:week_in_study)

        expect(view).to receive(:goal_like_count)
      end

      it "displays when then goal was created" do
        render partial: partial

        expect(rendered).to have_text goal.created_at.to_s(:standard)
      end

      it "displays participant's display name" do
        render partial: partial

        expect(rendered).to have_text "bar"
      end

      it "displays the goal's description" do
        render partial: partial

        expect(rendered).to have_text "foo"
      end

      describe "completion status" do
        describe "when a goal has been completed" do
          it "returns completion time" do
            allow(goal).to receive(:completed_at) { Time.zone.now - 1.day }

            render partial: partial

            expect(rendered).to have_text goal.completed_at.to_s(:standard)
          end
        end

        describe "when a goal is incomplete" do
          it "returns incomplete message" do
            render partial: partial

            expect(rendered).to have_text "incomplete"
          end
        end
      end

      describe "deleted status" do
        describe "when a goal has been deleted" do
          it "returns deleted time" do
            allow(goal).to receive(:deleted_at) { Time.zone.now - 1.day }

            render partial: partial

            expect(rendered).to have_text goal.deleted_at.to_s(:standard)
          end
        end

        describe "when a goal has not been deleted" do
          it "returns deleted message" do
            render partial: partial

            expect(rendered).to have_text "not deleted"
          end
        end
      end

      describe "schedule status" do
        describe "when a goal has been scheduled" do
          it "returns due date" do
            allow(goal).to receive(:due_on) { Date.today }

            render partial: partial

            expect(rendered).to have_text goal.due_on.to_s(:user_date)
          end
        end

        describe "when a goal has not been deleted" do
          it "returns unscheduled message" do
            render partial: partial

            expect(rendered).to have_text "Unscheduled"
          end
        end
      end
    end
  end
end
