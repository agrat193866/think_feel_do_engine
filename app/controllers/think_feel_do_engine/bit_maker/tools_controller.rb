module ThinkFeelDoEngine
  module BitMaker
    # Enables Admins to create, update, and delete tools
    # These tools are on the landing page for participants
    class ToolsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_tool, only: [:show, :edit, :update, :destroy]
      load_and_authorize_resource only: [:show, :edit, :update, :destroy]
      layout "manage"

      # GET /tools
      def index
        @tools = BitCore::Tool.all
        authorize! :index, @tools
      end

      # GET /tools/1
      def show
      end

      # GET /tools/new
      def new
        @tool = BitCore::Tool.new
        authorize! :index, @tool
      end

      # GET /tools/1/edit
      def edit
      end

      # POST /tools
      def create
        @tool = BitCore::Tool.new(tool_params)

        if @tool.save
          redirect_to bit_maker_tool_path(@tool),
                      notice: "Tool was successfully created."
        else
          render :new
        end
      end

      # PATCH/PUT /tools/1
      def update
        if @tool.update(tool_params)
          redirect_to bit_maker_tool_path(@tool),
                      notice: "Tool was successfully updated."
        else
          render :edit
        end
      end

      # DELETE /tools/1
      def destroy
        BitCore::Tool.transaction do
          @tool.content_modules.each do |cm|
            ids = cm.content_provider_ids
            ContentProviderPolicy.where(bit_core_content_provider_id: ids)
              .destroy_all || fail(ActiveRecord::Rollback)
            Task.where(bit_core_content_module_id: cm.id).destroy_all ||
              fail(ActiveRecord::Rollback)
            cm.destroy!
          end
          @tool.destroy!
        end

        redirect_to bit_maker_tools_url,
                    notice: "Tool was successfully destroyed."
      rescue
        redirect_to bit_maker_tools_url, alert: "Could not destroy tool."
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_tool
        @tool = BitCore::Tool.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def tool_params
        params.require(:tool).permit(:title, :position)
      end
    end
  end
end
