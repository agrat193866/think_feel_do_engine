module ThinkFeelDoEngine
  module BitMaker
    # Enables users to create, update, and delete modules
    # These modules contain providers that display content to the participants
    class ContentModulesController < ApplicationController
      before_action :authenticate_user!, :set_arm, :set_tools
      before_action :set_content_module, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource only: [:show, :edit, :update, :destroy]
      layout "manage"

      # GET /content_modules
      def index
        authorize! :index, @tools
      end

      # GET /content_modules/1
      def show
      end

      # GET /content_modules/new
      def new
        @content_module = BitCore::ContentModule.new
        authorize! :create, @content_module
      end

      # GET /content_modules/1/edit
      def edit
      end

      # POST /content_modules
      def create
        @content_module = BitCore::ContentModule.new(content_module_params)

        if @content_module.save
          redirect_to arm_bit_maker_content_module_path(@arm, @content_module),
                      notice: "Content module was successfully created."
        else
          render :new
        end
      end

      # PATCH/PUT /content_modules/1
      def update
        if @content_module.update(content_module_params)
          redirect_to arm_bit_maker_content_module_path(@arm, @content_module),
                      notice: "Content module was successfully updated."
        else
          render :edit
        end
      end

      # DELETE /content_modules/1
      def destroy
        if content_module_destroyed
          redirect_to arm_bit_maker_content_modules_path(@arm),
                      notice: "Content module along with any\
                      associated tasks were successfully destroyed."
        else
          redirect_to arm_bit_maker_content_modules_path(@arm),
                      alert: "There were errors"
        end
      end

      private

      def content_module_destroyed
        BitCore::ContentModule.transaction do
          ids = @content_module.content_provider_ids
          ContentProviderPolicy.where(bit_core_content_provider_id: ids)
            .destroy_all

          if tasks_destroyed
            @content_module.destroy!

            true
          else
            fail ActiveRecord::Rollback
          end
        end
      rescue
        false
      end

      def content_module_params
        params.require(:content_module).permit(
          :title, :bit_core_tool_id, :position
        )
      end

      def set_arm
        @arm = Arm.find(params[:arm_id])
      end

      def set_content_module
        @content_module = BitCore::ContentModule
                            .where(bit_core_tool_id: @arm.bit_core_tools.map(&:id))
                            .find(params[:id])
      end

      def set_tools
        @tools = @arm.bit_core_tools
      end

      def tasks_destroyed
        Task.where(bit_core_content_module_id: @content_module.id).destroy_all
      end
    end
  end
end
