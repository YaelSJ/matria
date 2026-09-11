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

  resources :cases do
    resources :case_files, except: [:index]
    member do
      post :submit_for_review
      post :decide
      post :start_review
    end

  end


  get "dashboard", to: "dashboards#show", as: :dashboard
  patch "cases/:id/assign", to: "cases#assign", as: :assign_case

end
