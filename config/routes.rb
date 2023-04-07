Rails.application.routes.draw do
  devise_for :users
  resources :movies do
    collection do
      get 'search'
      get 'recommend'
    end
  end
  root 'movies#search'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
