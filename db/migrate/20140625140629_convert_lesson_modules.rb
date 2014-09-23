class ConvertLessonModules < ActiveRecord::Migration
  def change
    BitCore::ContentModule.reset_column_information
    learn_tool = BitCore::Tool.find_by_title("LEARN")

    if learn_tool
      learn_tool.content_modules.each do |mod|
        mod.update!(type: "ContentModules::LessonModule")
      end
    end
  end
end
