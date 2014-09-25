module ThinkFeelDoEngine
  class Engine < ::Rails::Engine
    isolate_namespace ThinkFeelDoEngine

    config.to_prepare do
      Devise::SessionsController.layout "think_feel_do_engine"
    end

    initializer "think_feel_do_engine.action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        helper ThinkFeelDoEngine::TasksHelper
        helper ThinkFeelDoEngine::NavbarHelper
      end
    end
  end
end
