require "devise"

module ThinkFeelDoEngine
  # Uses the Navigator to direct a participant"s flow through the site.
  class NavigatorController < ApplicationController
    include Concerns::NavigatorEnabled
    before_action :authenticate_participant!, :instantiate_navigator

    layout "tool"

    def show_context
      context_name = params[:context_name] || home_tool.try(:title)
      @navigator.initialize_context(context_name)

      render "show_content"
    end

    def show_location
      @navigator.initialize_location(
        module_id: params[:module_id],
        provider_id: params[:provider_id],
        content_position: params[:content_position]
      )
    rescue ActiveRecord::RecordNotFound
      @navigator.initialize_context(home_tool.title)
      flash[:alert] = "Unable to find that module."
    ensure
      render "show_content"
    end

    def show_next_content
      mark_engagement_completed
      @navigator.fetch_next_content
      redirect_to navigator_location_path(
        module_id: @navigator.current_module.try(:id),
        provider_id: @navigator.current_content_provider.try(:id),
        content_position: @navigator.content_position
      )
    end

    def show_previous_content
      @navigator.fetch_previous_content
      redirect_to navigator_location_path(
        module_id: @navigator.current_module.try(:id),
        provider_id: @navigator.current_content_provider.try(:id),
        content_position: @navigator.content_position
      )
    end

    # Seek and redirect to the next content provider in order.
    def show_next_provider
      current_provider = @navigator.current_content_provider
      next_provider = current_provider

      while next_provider == current_provider
        @navigator.fetch_next_content
        next_provider = @navigator.current_content_provider
      end

      redirect_to navigator_location_path(
        module_id: @navigator.current_module.try(:id),
        provider_id: @navigator.current_content_provider.try(:id),
        content_position: @navigator.content_position
      )
    end

    private

    def last_engagment
      current_participant
        .active_membership
        .task_statuses
        .for_content_module(navigator_content_module)
        .try(:last)
        .try(:engagements)
        .try(:last)
    end

    def mark_engagement_completed
      if navigator_content_module && last_engagment
        last_engagment.update_attributes(completed_at: DateTime.current)
      end
    end

    def module_exist?
      @navigator
        .current_module
        .provider_exists?(@navigator.provider_position + 1)
    end

    def navigator_content_module
      @navigator.current_module || @navigator
        .current_content_provider
        .content_module
    end

    def provider_exist?
      @navigator
        .current_content_provider
        .exists?(@navigator.content_position + 1)
    end

    def home_tool
      current_participant.current_group
        .arm
        .bit_core_tools.find_by_type("Tools::Home")
    end
  end
end
