Rails.application.routes.draw do
  # get 'static_pages/home' #by default created routes
  get 'home', to: 'static_pages#home'  
  # get 'static_pages/help'
  get 'help', to: 'static_pages#help'  
  # get 'static_pages/about'
  get 'about', to: 'static_pages#about'  
  resources :posts
  resources :users
  root 'application#hello'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
