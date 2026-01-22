Rails.application.routes.draw do
  root "home#index"
  get "home/about-us"
  get "home/courses"
  get "up" => "rails/health#show", as: :rails_health_check

end
