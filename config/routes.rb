Rails.application.routes.draw do
  root to: 'static_pages#home'
  get '/user_index', to: 'users#index'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'

  resources :users, only:[:show,:edit,:update,:destroy]
end
