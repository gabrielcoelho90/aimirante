Rails.application.routes.draw do
  # Registers the Devise/Warden :user scope (needed for JWT strategy) without
  # adding any HTML routes — all auth goes through the custom API namespace below.
  devise_for :users, skip: :all

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :auth do
        post   "sign_up",  to: "registrations#create"
        post   "sign_in",  to: "sessions#create"
        delete "sign_out", to: "sessions#destroy"
        post   "refresh",  to: "sessions#refresh"
      end
    end
  end
end
