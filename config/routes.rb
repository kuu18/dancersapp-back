Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index create] do
        get :current_user, action: :show, on: :collection
        patch :update_profile, action: :update, on: :collection
        patch :chenge_email, action: :change_email, on: :collection
        patch :chenge_password, action: :change_password, on: :collection
        patch :avatar, action: :avatar, on: :collection
        patch :avatar_destroy, action: :avatar_destroy, on: :collection
        collection do
          get :following, :followers
        end
      end
      resources :eventposts, only: %i[index create destroy] do
        get :current_eventpost, action: :show, on: :collection
        get :user_eventposts, action: :user_eventposts, on: :collection
      end
      delete '/users', to: 'users#destroy'
      resources :login, only: [:create]
      delete '/logout', to: 'login#destroy'
      resources :account_activations, only: [:index]
      resources :password_resets,     only: %i[create index]
      patch '/password_resets', to: 'password_resets#update'
      resources :relationships, only: %i[create]
      delete '/relationships', to: 'relationships#destroy'
      resources :likes, only: %i[create index]
      delete '/likes', to: 'likes#destroy'
      resources :comments, only: [:create]
      delete '/comments', to: 'comments#destroy'
      resources :schedules, only: %i[create index] do
        get :my_schedules, action: :show, on: :collection
      end
      delete '/schedules', to: 'schedules#destroy'
      get :health_check, to: 'health_check#index'
    end
  end
end
