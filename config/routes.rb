Rails.application.routes.draw do
  get 'sessions/new'
  root to: 'static_pages#home'
  get '/user_index', to: 'users#index'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users, only:[:show,:edit,:update,:destroy]
end
