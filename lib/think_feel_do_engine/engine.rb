module ThinkFeelDoEngine
  class Engine < ::Rails::Engine
    isolate_namespace ThinkFeelDoEngine

    config.to_prepare do
      Devise::SessionsController.layout "think_feel_do_engine"
    end
  end
end
