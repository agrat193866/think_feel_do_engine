module ThinkFeelDoEngine
  module BitMaker
    # Enables creation and deletion of SlideshowAnchors.
    class SlideshowAnchorsController < ApplicationController
      before_action :authenticate_user!, :find_slideshow

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def create
        unless params[:slideshow_anchor]
          return destroy if params[:id_to_destroy].present?
          return render(js: "")
        end

        authorize! :create, SlideshowAnchor
        @slideshow_anchor = SlideshowAnchor.new(anchor_params)

        if @slideshow_anchor.save
          render "create", locals: { notice: "Anchor saved" }
        else
          render "create", locals: { alert: "Unable to save Anchor" }
        end
      end

      def destroy
        authorize! :destroy, SlideshowAnchor
        @slideshow_anchor = SlideshowAnchor.find(params[:id_to_destroy])

        if @slideshow_anchor.destroy
          render "destroy", locals: { notice: "Anchor deleted" }
        else
          render "destroy", locals: { alert: model_errors }
        end
      end

      private

      def find_slideshow
        @slideshow = BitCore::Slideshow.find(params[:slideshow_id])
      end

      def record_not_found
        render "destroy", locals: { alert: "Not found" }
      end

      def model_errors
        @slideshow_anchor.errors.full_messages.join(", ")
      end

      def anchor_params
        params.require(:slideshow_anchor)
          .permit(:target_name)
          .merge(bit_core_slideshow_id: @slideshow.id)
      end
    end
  end
end
