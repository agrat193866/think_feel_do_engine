module ThinkFeelDoEngine
  # Provides generic create and update methods for a participant's resources.
  class ParticipantDataController < ApplicationController
    include Concerns::NavigatorEnabled

    before_action :authenticate_participant!, :instantiate_navigator

    layout "tool"

    def create
      @data = current_participant.build_data_record(association, attributes)

      if @data.save
        flash[:notice] = provider.data_class_name.titleize + " saved"

        respond_to do |format|
          format.html { redirect_to navigator_next_content_url }
          format.js { render status: 201 }
        end
      else
        respond_with_error
      end
    end

    def update
      @data = current_participant
                .fetch_data_record(association, attributes[:id])

      if @data.update(attributes.reject { |a| a == "id" })
        flash[:notice] = provider.data_class_name.titleize + " saved"

        respond_to do |format|
          format.html { redirect_to navigator_next_content_url }
          format.js {}
        end
      else
        respond_with_error
      end
    end

    private

    def provider
      @provider ||= @navigator.current_content_provider
    end

    def singular_association
      @singular_association ||= provider.data_class_name.underscore
    end

    def association
      singular_association.pluralize
    end

    def attributes
      @attributes ||= params
        .fetch(singular_association, {})
        .permit(provider.data_attributes)
    end

    def respond_with_error
      flash.now[:alert] = @data.errors.full_messages.join(", ")

      respond_to do |format|
        format.html do
          render template: "think_feel_do_engine/navigator/show_content"
        end
        format.js { render status: 400 }
        format.json  { render json: { status: "error" } }
      end
    end
  end
end
