Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create] do
        get :current_user, action: :show, on: :collection
        patch :update_profile, action: :update, on: :collection
        patch :chenge_email, action: :change_email, on: :collection
        patch :chenge_password, action: :change_password, on: :collection
      end
      resources :eventposts, only: %i[index create destroy]
      delete '/users', to: 'users#destroy'
      resources :login, only: [:create]
      delete '/logout', to: 'login#destroy'
      resources :account_activations, only: [:index]
      resources :password_resets,     only: %i[create index]
      patch '/password_resets', to: 'password_resets#update'
    end
  end
end
