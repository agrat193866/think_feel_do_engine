Rails.application.routes.draw do
  mount ThinkFeelDoEngine::Engine => ""
  mount EventCapture::Engine => "event_capture"
  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)
end
