module ThinkFeelDoEngine
  module BitMaker
    # Enables Admins to create, update, and delete content providers
    # Content providers display the unique views that participants
    # As they traverse each tool each day
    class ContentProvidersController < ApplicationController
      before_action :authenticate_user!, :set_arm,
                    :set_content_modules, :set_slideshows

      layout "manage"

      def index
        authorize! :index, BitCore::ContentProvider
        @content_providers = BitCore::ContentProvider.all
      end

      def show
        authorize! :show, BitCore::ContentProvider
        @content_provider = find_content_provider

        if @content_provider.source_content_id
          @slideshow = @content_provider.source_content
        end
      end

      def new
        authorize! :new, BitCore::ContentProvider
        @content_provider = ContentProviderDecorator.new
      end

      def edit
        authorize! :edit, BitCore::ContentProvider
        @content_provider = find_content_provider
      end

      def create
        authorize! :create, BitCore::ContentProvider
        @content_provider = ContentProviderDecorator
                            .new(content_provider_params)

        if @content_provider.save
          redirect_to arm_bit_maker_content_provider_path(
            @arm, @content_provider
          ), notice: "ContentProvider was successfully created."
        else
          flash.now[:alert] = "Unable to save ContentProvider " +
            model_errors
          render :new
        end
      end

      def update
        authorize! :update, BitCore::ContentProvider
        @content_provider = find_content_provider

        if @content_provider.update(content_provider_params)
          redirect_to arm_bit_maker_content_provider_path(
            @arm, @content_provider
          ), notice: "ContentProvider was successfully updated."
        else
          flash.now[:alert] = "Unable to save ContentProvider " +
            model_errors
          render :edit
        end
      end

      def destroy
        authorize! :destroy, BitCore::ContentProvider
        @content_provider = find_content_provider

        if @content_provider.destroy
          redirect_to arm_bit_maker_content_providers_url(@arm),
                      notice: "Content provider was successfully destroyed."
        else
          redirect_to arm_bit_maker_content_providers_url(@arm),
                      alert: "Unable to delete ContentProvider " +
                        model_errors
        end
      end

      private

      def find_content_provider
        ContentProviderDecorator.fetch(params[:id])
      end

      def content_provider_params
        params.require(:content_provider).permit(
          :type, :source_content_type,
          :source_content_id, :bit_core_content_module_id,
          :position, :show_next_nav, :is_skippable_after_first_viewing,
          :template_path
        )
      end

      def model_errors
        @content_provider.errors.full_messages.join(", ")
      end

      def set_arm
        @arm = Arm.find(params[:arm_id])
      end

      def set_content_modules
        @content_modules = BitCore::ContentModule.where(bit_core_tool_id: @arm.bit_core_tools.map(&:id))
      end

      def set_slideshows
        @slideshows = BitCore::Slideshow.all
      end
    end
  end
end
