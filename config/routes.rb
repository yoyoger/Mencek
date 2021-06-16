Rails.application.routes.draw do
  get 'markings/create'
  get 'markings/destroy'
  root to: 'static_pages#home'

  get   '/user_index',    to: 'users#index'
  get   '/signup',        to: 'users#new'
  post  '/signup',        to: 'users#create'
  get   '/edit_user/:id', to: 'users#edit', as: 'edit_user'
  patch '/edit_user/:id', to: 'users#update'
  patch  '/resend_activation_email',  to: 'users#resend_activation_email'

  get '/login',      to: 'sessions#new'
  post '/login',     to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get '/posts/:id',      to: 'microposts#show', as: 'post'
  get '/postit',         to: 'microposts#new'
  post '/postit',        to: 'microposts#create'
  delete '/posts/:id',   to: 'microposts#destroy', as: 'delete_post'

  get    '/password_reset',     to: 'password_resets#new', as: 'new_password_reset'
  post   '/password_reset',     to: 'password_resets#create', as: 'create_password_reset'
  get    '/password_reset/:id', to: 'password_resets#edit', as: 'edit_password_reset'
  patch  '/password_reset/:id', to: 'password_resets#update', as: 'update_password_reset'

  post '/want_eat', to: 'markings#create', as: 'want_eat'
  delete '/unwant_eat/:id', to: 'markings#destroy', as: 'unwant_eat'

  resources :users, only:[:show,:destroy]
  resources :users, only:[:following,:followers] do
    member do
      get :following, :followers
    end
  end
  resources :relationships, only:[:create,:destroy]
  resources :account_activations, only: [:edit]
end
