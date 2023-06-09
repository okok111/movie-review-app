Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  resources :movies do
    collection do
      get 'search'
      get 'recommend'
    end
  end
  resources :posts
  root 'movies#search'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
