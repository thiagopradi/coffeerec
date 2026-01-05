Rails.application.routes.draw do
  # Landing page with email capture
  root "welcome#index"
  post "start", to: "welcome#create", as: :start

  # Quiz flow
  resource :taste_profile, only: [ :new, :create ]

  # Recommendations
  resources :recommendations, only: [ :index ]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
