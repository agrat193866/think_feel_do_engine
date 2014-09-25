Rails.application.routes.draw do
  mount ThinkFeelDoEngine::Engine => ""
  mount EventCapture::Engine => "event_capture"
  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)

  root to: "think_feel_do_engine/navigator#show_context"
end
