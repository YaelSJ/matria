Rails.application.routes.draw do
  devise_for :users,
             controllers: { registrations: "users/registrations" }

  authenticated :user do
    root to: "dashboards#show", as: :authenticated_root
  end

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  get "up" => "rails/health#show", as: :rails_health_check

  resources :cases, only: [:show, :edit, :update] do
    resources :case_files, only: [:new, :create]

    member do
      get :review_transcription
      post :confirm_transcription
      post :submit_for_review
      post :decide
      post :start_review
    end
  end

  get "dashboard", to: "dashboards#show", as: :dashboard
  patch "cases/:id/assign", to: "cases#assign", as: :assign_case

  delete "dashboard/activities/:id",
       to: "dashboards#dismiss_activity",
       as: :dismiss_dashboard_activity
end
