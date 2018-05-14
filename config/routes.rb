Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'account_activations/edit'
  get 'sessions/new'
  # get 'static_pages/home' #by default created routes
  get 'home', to: 'static_pages#home'  
  # get 'static_pages/help'
  get 'help', to: 'static_pages#help'  
  # get 'static_pages/about'
  get 'about', to: 'static_pages#about'  
  resources :posts
  resources :users
  root 'application#hello' 
  get  'signup', to: 'users#new'
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]


 # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
