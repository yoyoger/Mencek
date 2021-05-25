Rails.application.routes.draw do
  root to: 'static_pages#home'

  get '/user_index', to: 'users#index'
  get '/signup',     to: 'users#new'
  post '/signup',    to: 'users#create'

  get '/login',      to: 'sessions#new'
  post '/login',     to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get '/posts/:id',      to: 'microposts#show', as: 'post'
  get '/postit',         to: 'microposts#new'
  post '/postit',        to: 'microposts#create'
  delete '/posts/:id',   to: 'microposts#destroy', as: 'delete_post'

  resources :users, only:[:show,:edit,:update,:destroy]
end
