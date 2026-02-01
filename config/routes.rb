Rails.application.routes.draw do
  root "home#index"
  get "about-us", to: "home#about_us", as: :about_us
  get "join-us", to: "home#join_us", as: :join_us
  get "contact-us", to: "home#contact_us", as: :contact_us
  get "team", to: "home#team", as: :team
  get "gallery", to: "home#gallery", as: :gallery
  get "faq", to: "home#faq", as: :faq
  get "home/courses"
  get "up" => "rails/health#show", as: :rails_health_check

end
