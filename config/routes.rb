ThinkFeelDoEngine::Engine.routes.draw do
  devise_for :participants,
             module: :devise,
             controllers: { sessions: "think_feel_do_engine/participants/sessions" }
  devise_for :users,
             module: :devise,
             controllers: {
                            sessions: "think_feel_do_engine/users/sessions",
                            passwords: "think_feel_do_engine/users/passwords"
                          }

  get "navigator/previous_content", to: "navigator#show_previous_content", as: "navigator_previous_content"
  get "navigator/next_content", to: "navigator#show_next_content", as: "navigator_next_content"
  get "navigator/next_provider", to: "navigator#show_next_provider", as: "navigator_next_provider"
  get "navigator/contexts/:context_name", to: "navigator#show_context", as: "navigator_context"
  get "navigator/modules/:module_id(/providers/:provider_id/:content_position)", to: "navigator#show_location", as: "navigator_location"

  resource :participant_data, only: [:create, :update]

  resource :privacy_policy, only: [:show]

  namespace :manage do
    resources :groups, only: [] do
      resources :tasks, only: [:index]
    end
    resources :tasks, only: [:create, :update, :destroy]
  end

  resources :coach_dashboard, only: :index

  resources :arms, only: [:index, :show] do
    resources :content_dashboard, only: :index
    namespace :manage do
      get "groups/:id/edit_tasks", to: "groups#edit_tasks", as: "tasks_group"
    end
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
    end

    get "lessons/all_content", as: "lessons_all_content"

    resources :lessons do
      collection { post :sort }
      resources :lesson_slides do
        collection { post :sort }
      end
    end
  end

  namespace :coach do
    resources :messages, only: [:index, :new, :create]
    resources :patient_dashboards
    resources :phq_assessments
    resources :received_messages, only: :show
    resources :sent_messages, only: :show
    get "participant_activities_visualization/:participant_id",
        to: "participant_activities_visualizations#show",
        as: "participant_activities_visualization"
    get "participant_thoughts_visualization/:participant_id",
        to: "participant_thoughts_visualizations#show",
        as: "participant_thoughts_visualization"
  end

  resources :site_messages, only: [:index, :show, :new, :create]

  resources :memberships, only: :update

  namespace :participants do
    resources :phq_assessments, only: [:new, :create]
    resources :received_messages, only: :index
    resources :task_status, only: [:update]
    get "public_slideshows/:slideshow_id/slides/:id", to: "public_slides#show", as: "public_slideshow_slide"
    resources :thoughts, only: :create
    resources :activities, only: :create
  end

  get "keepalive", to: "keep_alive#index"

  get "password_entropy_bits", to: "password_entropy_bits#show", as: "password_entropy_bits"

  if Rails.env == "development"
    get "quick_sign_in", to: "quick_sign_ins#new", as: "quick_sign_in"
  end
end
