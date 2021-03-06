Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create] do
        get :current_user, action: :show, on: :collection
      end
      resources :login, only: [:create]
      delete 'logout', to: 'login#destroy'
    end
  end
end
