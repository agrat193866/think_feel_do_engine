module ThinkFeelDoDashboard
  module Reports
    # Models necessary for ability file to compile in specs.
    report_classes = %w(
      Comment
      Goal
      LessonModule
      LessonSlideView
      LessonViewing
      Like
      Login
      ModulePageView
      ModuleSession
      Nudge
      OffTopicPost
      SiteSession
      TaskCompletion
      ToolAccess
      ToolModule
      ToolShare
      UserAgent
      VideoSession
      PhqAssessment
    )

    report_classes.each do |klass|
      const_set(klass, nil)
    end
  end
end