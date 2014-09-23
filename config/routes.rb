ThinkFeelDoEngine::Engine.routes.draw do
  devise_for :participants,
             module: :devise,
             controllers: { sessions: "think_feel_do_engine/participants/sessions" }
  devise_for :users,
             module: :devise,
             controllers: { sessions: "think_feel_do_engine/users/sessions" }
  mount RailsAdmin::Engine => "/admin", :as => "rails_admin"

  get "navigator/previous_content", to: "navigator#show_previous_content", as: "navigator_previous_content"
  get "navigator/next_content", to: "navigator#show_next_content", as: "navigator_next_content"
  get "navigator/next_provider", to: "navigator#show_next_provider", as: "navigator_next_provider"
  get "navigator/contexts/:context_name", to: "navigator#show_context", as: "navigator_context"
  get "navigator/modules/:module_id(/providers/:provider_id/:content_position)", to: "navigator#show_location", as: "navigator_location"
  resource :participant_data, only: [:create, :update]

  namespace :bit_maker do
    resources :tools
    resources :content_modules
    resources :content_providers
    resources :slideshows do
      resources :slides do
        collection { post :sort }
      end
      resources :slideshow_anchors, only: [:create, :destroy]
    end
    resources :slides, only: [:index]
  end

  resources :lessons do
    collection { post :sort }
    resources :lesson_slides do
      collection { post :sort }
    end
  end

  resource :privacy_policy, only: [:show]

  namespace :manage do
    get "groups/:id/edit_tasks", to: "groups#edit_tasks", as: "tasks_group"
    resources :groups, only: [:index] do
      resources :tasks, only: [:index]
    end
    resources :tasks, only: [:create, :update, :destroy]
  end

  namespace :coach do
    resources :messages, only: [:index, :new, :create]
    resources :received_messages, only: :show
    resources :sent_messages, only: :show
    resources :patient_dashboards
    resources :phq_assessments
  end

  resources :memberships, only: :update

  namespace :participants do
    resources :phq_assessments, only: [:new, :create]
    resources :received_messages, only: :index
    resources :task_status, only: [:update]
    get "slideshows/:slideshow_id/slides/:id", to: "slides#show", as: "slideshow_slide"
  end

  get "password_entropy_bits", to: "password_entropy_bits#show", as: "password_entropy_bits"

  if Rails.env == "development"
    get "quick_sign_in", to: "quick_sign_ins#new", as: "quick_sign_in"
  end

  root to: "navigator#show_context"
end
