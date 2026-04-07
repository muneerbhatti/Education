Rails.application.routes.draw do
  devise_for :users
  post "newsletter/subscribe", to: "newsletters#subscribe"
  post "newsletter/unsubscribe", to: "newsletters#unsubscribe"
  get "newsletter/subscribed", to: "newsletters#subscribed", as: :newsletter_subscribed
  namespace :admin do
    resources :website_details
    resources :services
    resources :courses
    resources :instructors
    resources :newsletters do
      collection do
        get :subscribed
        get :unsubscribed
      end
    end
    root to: "services#index"
  end
  root "home#index"
  get "about-us", to: "home#about_us", as: :about_us
  get "join-us", to: "home#join_us", as: :join_us
  get "contact-us", to: "home#contact_us", as: :contact_us
  get "team", to: "home#team", as: :team
  get "gallery", to: "home#gallery", as: :gallery
  get "faq", to: "home#faq", as: :faq
  get "courses", to: "home#courses", as: :courses
  get "up" => "rails/health#show", as: :rails_health_check
end
