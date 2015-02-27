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
    end
  end
end
