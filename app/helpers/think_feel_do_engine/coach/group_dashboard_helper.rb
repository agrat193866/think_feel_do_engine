module ThinkFeelDoEngine
  module Coach
    # Displays navigational information in the form of breadcrumbs
    module GroupDashboardHelper
      def social_likes_and_comments_column_headers
        if social_features?
          content_tag(:th, "Likes") +
            content_tag(:th, "Comments")
        end
      end

      def social_likes_and_comments_count_rows(shared_item)
        if social_features?
          content_tag(:td, like_count(shared_item)) +
            content_tag(:td, comment_count(shared_item))
        end
      end

      def like_count(shared_item)
        like_count = 0
        SocialNetworking::SharedItem.where(item: shared_item).each do |item|
          like_count += SocialNetworking::Like.where(item: item).count
        end
        like_count
      end

      def comment_count(shared_item)
        comment_count = 0
        SocialNetworking::SharedItem.where(item: shared_item).each do |item|
          comment_count += SocialNetworking::Comment.where(item: item).count
        end
        comment_count
      end

      def week_in_study(date, membership)
        if (day_in_study(date, membership) / 7.0).ceil == 0
          1
        else
          (day_in_study(date, membership) / 7.0).ceil
        end
      end

      def day_in_study(date, membership)
        date.to_date - membership.start_date + 1
      end

      def comment_item_description(comment)
        case comment.item_type
        when "SocialNetworking::OnTheMindStatement"
          "OnTheMindStatement: "\
          "#{SocialNetworking::
              OnTheMindStatement.find(comment.item_id).description}"
        when "SocialNetworking::SharedItem"
          comment_shared_item_description(comment)
        else
          "Unknown Item Type, Item ID:#{comment.item_id},"\
          " Item Type: #{comment.item_type}"
        end
      end

      def participants_that_read_lesson(task)
        render partial: "think_feel_do_engine/coach/group_dashboard/"\
                        "lesson_completion_breakdown",
               locals: { task: task }
      end

      def list_participant_names(group, participants)
        participant_list = "<ul>"
        participants.each do |participant|
          participant_list +=
          "<li>#{link_to participant.display_name,
                         coach_group_patient_dashboard_path(
                           group, participant)}</li>" if participant
        end
        participant_list += "</ul>"
        participant_list
      end

      def comment_shared_item_description(comment)
        if comment.item
          case comment.item.item_type
          when "Activity"
            activity = Activity.find(comment.item.item_id)
            "Activity: #{activity.participant.study_id},"\
              " #{activity.activity_type.title}, #{comment.item.action_type}"
          when "SocialNetworking::Profile"
            "ProfileCreation: #{comment.participant.study_id}"
          when "SocialNetworking::Goal"
            goal = SocialNetworking::Goal.find(comment.item.item_id)
            "Goal: #{goal.participant.study_id}, #{goal.description}"
          when "Thought"
            thought = Thought.find(comment.item.item_id)
            "Thought: #{thought.participant.study_id}, #{thought.description}"
          else
            "Unknown SharedItem Type, Item ID:#{comment.item_id},"\
            " Item Type: #{comment.item_type}"
          end
        else
          "Comment was made for an unknown item."
        end
      end

      def activity_status(activity)
        if activity.monitored?
          "monitored"
        elsif activity.planned?
          "planned"
        elsif activity.reviewed_and_complete?
          "reviewed and complete"
        elsif activity.reviewed_and_incomplete?
          "reviewed and incomplete"
        end
      end

      def not_nil_and_populated_string(string_to_check)
        string_to_check && !string_to_check.empty?
      end

      def goal_like_count(goal)
        like_total = 0
        goal_shared_items =
          SocialNetworking::SharedItem
          .where(item_type: "SocialNetworking::Goal", item_id: goal.id)
        goal_shared_items.each do |item|
          like_total +=
            SocialNetworking::Like
            .where(item_type: "SocialNetworking::SharedItem",
                   item_id: item.id).count
        end
        like_total
      end

      private

      def week_of_task(task)
        if (task.task_statuses.first.start_day / 7.0).ceil == 0
          1
        else
          (task.task_statuses.first.start_day / 7.0).ceil
        end
      end
    end
  end
end
