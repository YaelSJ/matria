Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"


  get "up" => "rails/health#show", as: :rails_health_check

  resources :cases do
    resources :case_files, except: [:index]
  end


  get "dashboard", to: "dashboards#show", as: :dashboard


end
