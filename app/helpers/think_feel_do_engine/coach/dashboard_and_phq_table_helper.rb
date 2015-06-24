module ThinkFeelDoEngine
  module Coach
    # Provides helpers for patient dashboard index and phq9 table
    module DashboardAndPhqTableHelper
      attr_accessor :nil_step, :nil_stay, :step_or_nil_results,
                    :prev_range_start, :step_string, :stay_string,
                    :release_string, :test_summary, :step_label,
                    :stay_label, :release_label

      def init_summary_styles(test_summary)
        @nil_step = test_summary[:step?].nil?
        @nil_stay = test_summary[:stay?].nil?
        @step_or_nil_results = @nil_step || test_summary[:step?]
        define_strings(test_summary)
        define_labels(test_summary)
        @test_summary = test_summary
      end

      def result_span(text, label)
        content_tag(:span, text.to_s, class: "label label-" +
          label.to_s).html_safe
      end

      def edge_week?
        @test_summary[:current_week] == @test_summary[:range_start]
      end

      def view_membership(participant, group)
        Membership.find_by(participant: participant, group: group)
      end

      def study_length_in_weeks
        if Rails.application.config.respond_to?(:study_length_in_weeks)
          Rails.application.config.study_length_in_weeks
        end
      end

      private

      def set_string_result(tf_condition, na_condition)
        string = tf_condition ? "True" : "False"
        string = "N/A" if na_condition || tf_condition.nil?
        string
      end

      def reverse_label_styling(string, na_condition, tf_condition)
        if tf_condition
          string = "danger label-adj_danger"
        else
          string = "success label-adj_success"
        end
        string = "warning" if na_condition || tf_condition.nil?
        string
      end

      def set_label_result(string, na_condition, tf_condition, reverse)
        if reverse
          string = reverse_label_styling(string, na_condition, tf_condition)
          return string
        end
        string = tf_condition ? "success" : "danger"
        string = "warning" if na_condition || tf_condition.nil?
        string
      end

      def define_strings(test_summary)
        @step_string = set_string_result(test_summary[:step?],
                                         @nil_step)

        @stay_string = set_string_result(test_summary[:stay?],
                                         @step_or_nil_results ||
                                         @nil_stay)

        @release_string = set_string_result(test_summary[:release?],
                                            @step_or_nil_results)
      end

      def define_labels(test_summary)
        @step_label = set_label_result(@step_label,
                                       @nil_step,
                                       test_summary[:step?],
                                       true)
        @stay_label = set_label_result(@stay_label,
                                       @step_or_nil_results ||
                                       @nil_stay,
                                       test_summary[:stay?],
                                       false)
        @release_label = set_label_result(@release_label,
                                          @step_or_nil_results,
                                          test_summary[:release?],
                                          false)
      end
    end
  end
end
